# AI PROJECT

## Planing [10/31/2025]

1. Create a kick-off script that installs Git, clones the HomeAI repository, and installs Ansible's packages / dependencies. From there the machine can run the Ansible Playbooks locally to continue the process.

2. Set up fundamental operating system requirements for this project by first finishing the **ansible files**
    * Install the docker dependencies and docker daemon
    * Install Nvidia Drivers (assumes an Nvidia GPU)
    * Install Nvidia Container Toolkit
    * Runs the docker-compose file created in step 3

3. Create a basic **docker-compose** file to stand up and configure the core components of the project
    * **Open WebUI** for the front end and orchestration
    * **vLLM** for the LLM runtime
    * **NGINX** for reverse proxying the stack and providing a secure frontend with encryption
    * **CertBot** for renewal of certificates automatically
4. Custom Agents