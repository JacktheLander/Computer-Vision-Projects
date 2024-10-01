import torch
from CNN import SurgicalEquipmentNet
## For CUDA 11.7: pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu117

print(torch.cuda.is_available())  # Should return True if CUDA is available

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Move model to GPU
model = SurgicalEquipmentNet(num_classes=5).to(device)
