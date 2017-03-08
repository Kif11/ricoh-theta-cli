# CLI for Ricoh Theta S camera
This script provide command line interface for Ricoh Theta S 360 camera
Tested with:
- OSX Siera 10.12.3
- Bash 3.2.57
- Ricoh Firmware 1.82

## Install
You will need bash JSON parser called `jq`
```
brew install jq
```
Clone this repository and make thetas executable
```
git clone https://github.com/Kif11/ricoh-theta-cli
cd ricoh-theta-cli
sudo chmod +x thetas.sh
```
## Usage
Run init command to configure your camera. This will set to use Theta 2.0 API
If you getting an error when you should update your camera firmware
```
./thetas.sh init
```
Run thetas.sh to list all command
```
./thetas.sh
```
## Examples
Take a picture
```
./thetas.sh snap
```
Download latest picture
```
./thetas.sh getlast
```
List files on the camera
```
./thetas.sh list
```
