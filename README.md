# think2020

LAB Setup Instructions

1.1 Prerequisite


The LAB Part 1

Set up docker registry. 

1) add following line to the /etc/hosts

   ```bash
   169.62.153.153 thinkmoscow
   ```

2) depends on env you use add the certificate (will beprovided during the lab) to 

   ```bash
   /etc/docker/certs.d/thinkmoscow/ca.crt
   ```
   (for linux) or to 

   ```bash
   ~/.docker/certs.d/thinkmoscow/ca.crt
   ```
   (for mac os) and restart docker

3) run  
   ```bash
   docker login thinkmoscow
   ```
   (username and password will be provided to you during the lab) 
