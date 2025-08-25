# SVG to PDF converter
## Dependencies
* Ruby v3.4.5
* Rails v8.0.2.1
* Docker v28.3.0
* Docker-Compose v2.38.1

### First step: clone repository
```bash
git clone https://github.com/dwarowski/maxa-test-task.git
cd maxa-test-task
```

## Production
### Second step: setup configs
#### env
Create .env file and open it using your favorite text editor to set the key (if you don't have a key do credentials first) for rails docker. I`m gonna use nano
```bash
touch .env
nano .env
```

```bash
#---.env---
RAILS_MASTER_KEY=your_master_key
```
#### credentials
 
Usually you keep credentials key and yaml in your team but in this case we going to create a new credentials and a key
```bash
rm -rf credentials
EDITOR="nano" rails credentials:edit -e production
```
This command is going to open nano where you can edit the credentials if you need to. Also this command creates production.key change ``your_master_key`` to key inside file

### Third step: Docker
use docker-compose to setup app
```
docker-compose up -d --build
```