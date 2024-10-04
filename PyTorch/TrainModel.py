import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader
from torchvision import transforms
from DataLoader import SurgicalEquipmentDataset
from CNN import SurgicalEquipmentNet
import time
import datetime

# Function to save build progress
def save_checkpoint(model, optimizer, epoch, best_accuracy, file_path="checkpoint.pth"):
    # Create a dictionary to store everything needed to resume training
    checkpoint = {
        'model_state_dict': model.state_dict(),
        'optimizer_state_dict': optimizer.state_dict(),
        'epoch': epoch,
        'best_accuracy': best_accuracy,
    }
    torch.save(checkpoint, file_path)
    print(f"Checkpoint saved at epoch {epoch + 1} to {file_path}")

# Function to log epoch results to a file
def log_epoch(epoch, epoch_loss, epoch_acc, epoch_duration, log_file='log.txt'):
    """
    Logs epoch results to a file with a timestamp.

    Args:
    epoch (int): Current epoch number.
    epoch_loss (float): Loss for the current epoch.
    epoch_acc (float): Accuracy for the current epoch.
    epoch_duration (float): Duration of the epoch in seconds.
    log_file (str): Path to the log file. Default is 'training_log.txt'.
    """
    # Get the current timestamp
    timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    # Format the log entry
    log_entry = (f"[{timestamp}] Epoch [{epoch + 1}], Loss: {epoch_loss:.4f}, "
                 f"Accuracy: {epoch_acc:.2f}%, Time: {epoch_duration:.2f} seconds\n")

    # Append the log entry to the specified log file
    with open(log_file, 'a') as file:
        file.write(log_entry)
    print(f"Logged epoch {epoch + 1} to {log_file}")
    return

# Function to print gradient stats for specific layers
def check_gradients(model):
    for name, param in model.named_parameters():
        if param.grad is not None:
            print(f"Gradients of {name}: Min={param.grad.min().item()}, Max={param.grad.max().item()}, Mean={param.grad.mean().item()}")

# Training function
def train_model():
    # Configuration
    num_epochs = 20
    batch_size = 64
    learning_rate = 1e-4
    num_classes = 5

    # Define the data directory and text files
    root_dir = "Object-Classification\\Surgical-Dataset\\Images"
    train_txt = "Object-Classification\\Surgical-Dataset\\Test-Train Groups\\train-obj_detector.txt"

    # Define image transformations
    data_transforms = transforms.Compose([
        transforms.Grayscale(num_output_channels=1),
        transforms.Resize((224, 224)),
        transforms.RandomHorizontalFlip(),
        transforms.RandomRotation(10),
        transforms.RandomAffine(degrees=0, translate=(0.1, 0.1)),  # Random translations
        transforms.ToTensor(),
    ])

    # Create training dataset and loader
    train_dataset = SurgicalEquipmentDataset(root_dir=root_dir, file_list=train_txt, transform=data_transforms)
    train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True, num_workers=6, pin_memory=True)

    # Initialize the model and optimizer
    model = SurgicalEquipmentNet(num_classes=num_classes)  # Use the simplified network
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=learning_rate)

    scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(optimizer, 'min', patience=3, factor=0.1)

    # Move model to GPU if available
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model.to(device)

    print("Starting Training...")
    best_accuracy = 0.0

    try:
        for epoch in range(num_epochs):
            start_time = time.time()
            model.train()
            running_loss = 0.0
            correct = 0
            total = 0

            for batch_idx, (images, labels) in enumerate(train_loader):
                images, labels = images.to(device), labels.to(device)

                try:
                    outputs = model(images)

                    # Check for NaN in outputs before loss
                    if torch.isnan(outputs).any() or torch.isinf(outputs).any():
                        print(f"NaN or Inf detected in outputs for batch {batch_idx}. Skipping batch...")
                        continue

                    loss = criterion(outputs, labels)

                    optimizer.zero_grad()
                    loss.backward()

                    # Clip gradients to prevent explosions
                    torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)

                    optimizer.step()

                except RuntimeError as e:
                    print(f"RuntimeError in batch {batch_idx}: {e}. Skipping batch...")
                    continue

                # Calculate loss and accuracy
                running_loss += loss.item() * images.size(0)
                _, predicted = outputs.max(1)
                total += labels.size(0)
                correct += predicted.eq(labels).sum().item()

            epoch_loss = running_loss / len(train_loader.dataset)
            epoch_acc = 100. * correct / total
            epoch_duration = time.time() - start_time
            print(f"Epoch [{epoch + 1}/{num_epochs}], Loss: {epoch_loss:.4f}, Accuracy: {epoch_acc:.2f}%, Time: {epoch_duration:.2f} seconds")

            # Log the epoch results to a file
            log_epoch(epoch, epoch_loss, epoch_acc, epoch_duration, log_file='log.txt')

            # **Update the scheduler**
            scheduler.step(epoch_loss)

            # Save the model if it has the best accuracy so far
            if epoch_acc > best_accuracy:
                best_accuracy = epoch_acc
                torch.save(model.state_dict(), "best_model.pth")
                print(f"Best model saved with accuracy: {best_accuracy:.2f}%")
                save_checkpoint(model, optimizer, epoch, best_accuracy, file_path="checkpoint.pth")

    except KeyboardInterrupt:
        # Handle manual stop and save the state
        print(f"Training interrupted. Saving checkpoint at Epoch [{epoch + 1}].")
        save_checkpoint(model, optimizer, epoch, best_accuracy, "interrupted_checkpoint.pth")
        print(f"Checkpoint saved. You can resume from this point later.")

# Protect main script
if __name__ == '__main__':
    train_model()
