# DockerShield: Docker Security & Misconfiguration Auditor

DockerShield is a specialized tool for auditing the security of running Docker containers. While regular scanners look for vulnerabilities in the code, DockShield looks for errors in the startup configuration that may allow an attacker to "escape" from the container to the host system (Container Escape).

The project is aimed at system administrators and information security specialists working with modern environments based on Arch Linux, Ubuntu and CentOS.

## What risks does DockerShield identify

The script analyzes containers for the following critical threats:
* Privileged Mode: Identifies containers running with full access to host resources. This is a critical vulnerability that allows access to the core of the main OS
* Docker Socket Leak: Detects the mounting of /var/run/docker.sock. A container with socket access can manage the entire Docker daemon of the host
* Root-on-Container: Checks whether the process inside the container is running on behalf of the superuser (violating the principle of least privilege)
* Resource Exhaustion (DoS): Checks if there are no RAM limits, which can cause the entire server to crash during an attack inside the container
* Network Isolation: Detects the use of the --net=host mode, which opens the host's network interfaces directly to the container

## Quick start

Requirements
* Docker is installed and running
* Rights to read the Docker API (it is recommended to run via sudo or membership in the docker group)
```
https://github.com/S0LYER/docker-shield
cd docker-shield
chmod +x dockershield.sh
sudo ./dockershield.sh
```

## Test Lab

To see how DockShield reacts to vulnerabilities, you can run a test "insecure" container:
```
docker run -d --name vulnerable_node --privileged -v /var/run/docker.sock:/var/run/docker.sock alpine sleep 1000
```
Then run ./dockershield.sh and you will see a detailed report with red warnings about critical risks.

## Screenshot

<img width="582" height="458" alt="изображение" src="https://github.com/user-attachments/assets/c4ca3065-d97a-4be1-812a-c977f2df5635" />

## Disclaimer

The tool is intended to be used as part of an authorized security audit. The author is not responsible for the misuse of the script.

## Contributing

Improvement ideas are welcome!
1. Split the fork of the project.
2. Create an app for new users (git checkout -b/AmazingFeature feature)
3. Make a commit (git commit -m 'Add some amazing features')
4. Make a push (git push origin feature/AmazingFeature)
5. Make an extraction request
