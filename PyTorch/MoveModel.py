import shutil

# Source path: where the checkpoint file is currently saved
source_path = "best_model.pth"

# Destination path: where you want to copy the file
destination_path = "MyModels/[9-30_16.40].pth"

# Copy the file
shutil.copy(source_path, destination_path)
print(f"Checkpoint successfully copied to: {destination_path}")