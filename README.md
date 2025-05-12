# Django Ubuntu Server Setup Automation

This project automates the end-to-end setup of a production-ready Django application on a fresh Ubuntu server. It handles everything from initial server hardening to reverse proxy and SSL setup using best practices and commonly used tools.

## Features

* Automated creation and hardening of a new Linux user
* Installation and configuration of PostgreSQL
* Setup of Gunicorn as the application server
* Configuration of Nginx as a reverse proxy
* Free SSL certificate provisioning with Let's Encrypt (Certbot)
* Modular shell scripts for reusability and maintainability
* Single `.env` configuration for all parameters


## Description of Setup Scripts



---

## Description of Setup Scripts

The `set_up` directory contains a collection of shell scripts designed to automate the configuration of a server. Below is a brief description of each script:

* **clone_repo.sh**: Clones the project repository from a remote Git server.
* **copy\_project.sh**: Copies the project files to the appropriate directory on the server.
* **django\_setup.sh**: Configures the Django application, including settings and migrations.
* **essential\_packages.sh**: Installs essential packages required for the server's operation.
* **firewall\_setup.sh**: Configures the server's firewall to allow or block specific traffic.
* **gunicorn\_setup.sh**: Sets up Gunicorn as the application server for the Django project.
* **letsencrypt\_setup.sh**: Sets up Let's Encrypt for SSL/TLS certificates to secure web traffic.
* **nginx\_setup.sh**: Installs and configures the Nginx web server as a reverse proxy.
* **postgresql\_setup.sh**: Installs and configures PostgreSQL as the database server.
* **ssh\_setup.sh**: Sets up and secures SSH access to the server.
* **system\_update.sh**: Updates the system's package lists and installs the latest versions of installed packages.
* **user\_setup.sh**: Configures user accounts, including creating new users and setting permissions.

These scripts work together to streamline the server setup process, ensuring a secure and functional environment.

* **deploy\_setup.sh**: The main script that orchestrates the entire setup process by calling the other scripts in the correct order.
* **.env**: A configuration file where you can set environment variables for the setup process. This file should be created by the user, securely stored and should not be included in version control.
* **.gitignore**: Specifies files and directories that should be ignored by Git, including the `.env` file.
* **README.md**: This Documentation. It includes setup instructions and usage guidelines.

## Directory Structure

```

server_config/
├── deploy_setup.sh
├── .env (to be created by the user)
├── .gitignore
├── README.md
├── set_up/
│   ├── main_setup.sh
│   ├── utils/
│   │   ├── clone_repo.sh
│   │   ├── copy_project.sh
│   │   ├── django_setup.sh
│   │   ├── essential_packages.sh
│   │   ├── firewall_setup.sh
│   │   ├── gunicorn_setup.sh
│   │   ├── letsencrypt_setup.sh
│   │   ├── nginx_setup.sh
│   │   ├── postgresql_setup.sh
│   │   ├── ssh_setup.sh
│   │   ├── system_update.sh
│   │   ├── user_setup.sh

```

* Ubuntu 24.01 LTS (clean installation recommended)
* SSH access with sudo/root privileges

## Making Scripts Executable

To ensure all the setup scripts are executable, run the following command:

```bash
chmod +x set_up/*.sh
```

## Running the Setup Scripts

To run the setup process:

```bash
./deploy_setup.sh
```

## Contributing

Pull requests are welcome! If you find a bug, want to improve the process, or extend it for other frameworks, feel free to fork and PR.

## License

MIT License

---

**Let’s make Django deployment easy, fast, and repeatable.**
**Happy coding!**
```
