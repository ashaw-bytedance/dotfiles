#! bin/bash
# updates linux
# sets up dotfile config files and ssh keys
# installs latest nvidia drivers

sudo apt-get update -y
sudo apt-get -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confnew upgrade -y
sudo apt-get install emacs -y
sudo apt-get autoremove -y
sudo apt-get autoclean -y

# link bashrc things
git clone https://github.com/bearpelican/dotfiles.git
mv ~/.bashrc ~/.bashrc.bak
ln -s ~/dotfiles/server/.bashrc ~/.bashrc
source ~/.bashrc
ln -bfs ~/dotfiles/home/.gitconfig ~/.gitconfig # backup, force, symbolic
mkdir -p .jupyter/nbconfig
ln -bfs ~/dotfiles/jupyter/notebook.json ~/.jupyter/nbconfig/notebook.json
ln -bfs ~/dotfiles/server/.tmux.conf ~/.tmux.conf
tmux source-file ~/.tmux.conf

# generate keygen for ssh
if [ ! -f ~/.ssh/id_rsa.pub ]; then
    yes "" | ssh-keygen -t rsa -N ""
    echo "SSH Key generated. Please enter this into github:"
    cat ~/.ssh/id_rsa.pub
else
    echo "SSH Key already generated. Public key:"
    cat ~/.ssh/id_rsa.pub
fi

# install nvidia
sudo apt-get purge nvidia* -y
sudo apt-get autoremove -y
sudo apt-get autoclean -y
sudo rm -rf /usr/local/cuda*

sudo apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub
echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64 /" | sudo tee /etc/apt/sources.list.d/cuda.list

sudo apt-get update  -y
sudo apt-get -o Dpkg::Options::="--force-overwrite" install cuda-9-2 cuda-drivers -y

sudo ldconfig
nvidia-smi

# Install cudnn 7.2.1
CUDNN_FILE=cudnn-9.2-linux-x64-v7.2.1.38.tgz
wget https://s3-us-west-2.amazonaws.com/ashaw-fastai-imagenet/$CUDNN_FILE
tar -xf $CUDNN_FILE
sudo cp -R ~/cuda/include/* /usr/local/cuda-9.2/include
sudo cp -R ~/cuda/lib64/* /usr/local/cuda-9.2/lib64
rm $CUDNN_FILE
rm -rf ~/cuda

# Install nccl 2.2.13 - might not need this
wget https://s3-us-west-2.amazonaws.com/ashaw-fastai-imagenet/nccl_2.2.13-1%2Bcuda9.2_x86_64.txz
tar -xf nccl_2.2.13-1+cuda9.2_x86_64.txz
sudo cp -R ~/nccl_2.2.13-1+cuda9.2_x86_64/* /usr/local/cuda-9.2/targets/x86_64-linux/
# sudo cp -R ~/nccl_2.2.13-1+cuda9.2_x86_64/* /lib/nccl/cuda-9.2
sudo ldconfig
rm nccl_2.2.13-1+cuda9.2_x86_64.txz
rm -rf nccl_2.2.13-1+cuda9.2_x86_64

sudo apt-get install libcupti-dev

# MAY NEED TO REBOOT COMPUTER HERE
sudo reboot