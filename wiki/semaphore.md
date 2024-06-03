# setup semaphore config file :

- to begin with setting up semaphore we first need its docker compose file with some flags which you can take a closer look down below :

```yaml
volumes:
  semaphore-mysql:
    driver: local
services:
  mysql:
    image: mysql:8.0
    hostname: mysql
    volumes:
      - semaphore-mysql:/var/lib/mysql
    environment:
      - MYSQL_RANDOM_ROOT_PASSWORD=yes
      - MYSQL_DATABASE=semaphore
      - MYSQL_USER=semaphore
      - MYSQL_PASSWORD=Abc!23456789
    restart: unless-stopped
  semaphore:
    container_name: ansiblesemaphore
    image: semaphoreui/semaphore:v2.9.45
    user: "root"
    ports:
      - 3000:3000
    environment:
      - SEMAPHORE_DB_USER=semaphore
      - SEMAPHORE_DB_PASS=Ab
      - SEMAPHORE_DB_HOST=mysql
      - SEMAPHORE_DB_PORT=3306
      - SEMAPHORE_DB_DIALECT=mysql
      - SEMAPHORE_DB=semaphore
      - SEMAPHORE_PLAYBOOK_PATH=/tmp/semaphore/
      - SEMAPHORE_ADMIN_PASSWORD=Ab
      - SEMAPHORE_ADMIN_NAME=admin
      - SEMAPHORE_ADMIN_EMAIL=admin@localhost
      - SEMAPHORE_ADMIN=admin
      - SEMAPHORE_ACCESS_KEY_ENCRYPTION=gUQl2frMnUcsjOwhUGIa4p6bpXIiClcyI=  # add to your access key encryption !
      - ANSIBLE_HOST_KEY_CHECKING=false  # (optional) change to true if you want to enable host key checking
    volumes:
      - ./inventory/:/inventory:ro
      - ./authorized-keys/:/authorized-keys:ro
      - ./config/:/etc/semaphore:rw
    restart: unless-stopped
    depends_on:
      - mysql
```

- we can change values like sql username and password based on your requirements and for adding a value for SEMAPHORE_ACCESS_KEY_ENCRYPTION we need to generate 32-bit value that we can use the below command:

```bash
head -c32 /dev/urandom | base64
```

then run the command below to bring up docker compose :

```bash
docker-compose -f {yaml file name} up -d
```

- when we had our semaphore up we can access that via endpint : localhost:3000 as a default port
- our semaphore is working in a way that we have to give it our repository so that it would be able to fetch data from registry which includes our role and tasks,plabooks,etc i myself added our own gitlab registry and it connects to it via ssh
- hint: to make it available for semaphore to ssh to our gitlab which was brought up via container we first have to expose additional port for ssh connection to do that we add one line below in our ports section of gitlab compose file in this example i have exposed the port 2265 which docker will redirect it to internal port which is 22 by default :

```bash
2265:22
```

# configure semaphore UI & generate keys:

### generate keys for gitlab register:

- firstly we should generate public and private key by using the command below :

```bash
ssh-keygen
```

then we go to this path to grab our generated private key : **/$HOME/.ssh/id_rsa** afterwards we take it and add it in the section , private key now we can easily connect to our gitlab registry. in the next step we should take the public key named **id_rsa.pub** in the same path as private key and paste it in the section ssh key after creating ssh key for our own user in gitlab .

### generate keys for remote servers:

- in the next step we should generate another key pair for our remote server where we want to perform our actions on . then we have to run following command to transfer our generated public key to the remote server .

```bash
ssh-copy-id [target-user]@[remote server ip]
```

- now that we have generated key pair for our remote servers we can add another KEYSTORE for connecting to our remote server and perform the same way we did for gitlab .

# adding repository in semaphore:

* now that we have configured our keys we can assigne our registry to semaphore so that it finds out where to get its data from to do that we head to section repository in the sidebar the create a new repository .

we name our repository whatever we want then we should give it our registry path and let it know how semaphore should clone our data , as its shown we have multiple choices like https,ssh,... we use ssh because its more secure and safer.

```bash
ssh://git@[target-remote-server]:[exposed port e.g. 2265 ]/[path-of-git-project]
```

next, we assigne our branch and generated key name for accessing gitlab registry.

# env :

* we can pass some environment variables to our playbook using this section if not , just add the following lines to it and pass over to the next step.

  ```bash
  {}
  ```

# inventory :

* now we should pass our hosts or remote servers that we want to connect to . to do so i added the following lines :

  ```yaml
  [remoteserver]
  192.168.41.49
  [remoteserver:vars]
  ansible_ssh_user=sample
  ansible_ssh_port=22
  
  ```
* in this section i added one host which is **remoteserver** and passed the ip address of that remote host then i wanted to be able to make a ssh connection to this server targetting sample user with the default port 22 so that i added these to line of code.

# new template:

now it's time to create our first temlate to do so we give it a name and path of the playbook file in gitlab registery like : ping.yml

add fill the other sections like created inventory,keystores,repository,etc

in the final step we run our template that was all , 

good day. ...