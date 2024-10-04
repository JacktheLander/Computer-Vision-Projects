#
# Complete: Number of training images: 1834
#           Number of testing images: 786

import os
from PIL import Image
from torch.utils.data import Dataset, DataLoader
from torchvision import transforms
import torch


class SurgicalEquipmentDataset(Dataset):
    def __init__(self, root_dir, file_list, transform=None):
        """
        Args:
            root_dir (str): The root directory where the `all/images/` folder is located.
            file_list (str): Path to the text file listing all image filenames.
            transform (callable, optional): Transform to be applied on each image.
        """
        self.root_dir = os.path.join(root_dir, "all", "images")  # Root directory pointing to 'all/images/'
        self.transform = transform
        self.image_paths = []  # Store full image paths
        self.labels = []  # Store corresponding labels (integers)

        # Define a consistent class-to-index mapping (update this with your classes)
        class_names = ['bisturi', 'pinca', 'separado', 'tesouracurva', 'tesourareta']  # Modify as needed
        self.class_to_idx = {class_name: idx for idx, class_name in enumerate(class_names)}
        print(f"Class to Index Mapping: {self.class_to_idx}")

        # Load image paths from the `file_list` text file
        with open(file_list, 'r') as file:
            for line in file:
                image_filename = line.strip()
                if image_filename:
                    # Construct full path within `all/images/` folder
                    full_path = os.path.join(self.root_dir, image_filename)
                    if os.path.exists(full_path):
                        self.image_paths.append(full_path)

                        # Extract just the filename from the full path
                        actual_filename = os.path.basename(full_path)

                        # Infer the label from the filename
                        label = self.infer_label_from_filename(actual_filename)
                        if label in self.class_to_idx:
                            self.labels.append(self.class_to_idx[label])
                        else:
                            print(f"Warning: Inferred label '{label}' not in defined class list.")
                    else:
                        print(f"Warning: File {full_path} not found.")

        # Debug prints to check the lengths of both lists
        print(f"Number of image paths: {len(self.image_paths)}")
        print(f"Number of labels: {len(self.labels)}")
        if len(self.image_paths) != len(self.labels):
            print(f"Error: Mismatch between image paths ({len(self.image_paths)}) and labels ({len(self.labels)})")

    def infer_label_from_filename(self, filename):
        """
        Infers label from the filename by using part of the string.
        Args:
            filename (str): The filename of the image (e.g., "stretchers1.jpg").
        Returns:
            str: The inferred label.
        """
        class_label = ''.join([char for char in filename if not char.isdigit()]).split('.')[0]
        return class_label

    def __len__(self):
        return len(self.image_paths)

    def __getitem__(self, idx):
        # Load image using the full path and convert to grayscale (mode 'L')
        img_path = self.image_paths[idx]
        image = Image.open(img_path).convert('L')  # Use 'L' mode for grayscale

        # Get the label and ensure it's a LongTensor
        label = self.labels[idx]
        label = torch.tensor(label, dtype=torch.long)

        # Apply transformations if specified
        if self.transform:
            image = self.transform(image)

        return image, label

# Define image transformations
data_transforms = transforms.Compose([
    transforms.Grayscale(num_output_channels=1),  # Convert image to grayscale
    transforms.Resize((224, 224)),  # Resize to the same dimensions
    transforms.ToTensor(),  # Convert to tensor
])

# Update root directory and text file paths
root_dir = "\\Object-Classification\\Surgical-Dataset\\Images"
train_txt = "\\Object-Classification\\Surgical-Dataset\\Test-Train Groups\\train-obj_detector.txt"
test_txt = "\\Object-Classification\\Surgical-Dataset\\Test-Train Groups\\test-obj_detector.txt"

# Create datasets for training and testing
train_dataset = SurgicalEquipmentDataset(root_dir=root_dir, file_list=train_txt, transform=data_transforms)
test_dataset = SurgicalEquipmentDataset(root_dir=root_dir, file_list=test_txt, transform=data_transforms)

# Check dataset size and contents
print(f"Number of training images: {len(train_dataset)}")
print(f"Number of testing images: {len(test_dataset)}")

# Create DataLoaders
if len(train_dataset) > 0:
    train_loader = DataLoader(train_dataset, batch_size=32, shuffle=True)
if len(test_dataset) > 0:
    test_loader = DataLoader(test_dataset, batch_size=32, shuffle=False)
