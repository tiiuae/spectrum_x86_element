#    Check out source tree:

    git clone https://spectrum-os.org/git/spectrum
    git clone https://github.com/NixOS/nixpkgs
    git clone -b rootfs --reference nixpkgs \
      https://spectrum-os.org/git/nixpkgs nixpkgs-spectrum

You may also want to setup binary cache as it described in  

Change dir to ./spectrum/vm/app/:

    [vadikas@nixos:~/spectrumos]$ cd spectrum/vm/app/
    [vadikas@nixos:~/spectrumos/spectrum/vm/app]$ ls
    catgirl  lynx  usbapp

# Copy one of the sample apps (these are folders) : catgirl is wayland chatapp, lynx is a console-based browser,  usbapp is an example app setup to use usb devices in VM.

    [vadikas@nixos:~/spectrumos/spectrum/vm/app]$ cp -Rp usbapp myapp && cd myapp

    [vadikas@nixos:~/spectrumos/spectrum/vm/app/myapp]$ ls -al
    total 28
    drwxr-xr-x 4 vadikas users 4096  8. 9. 17:53 .
    drwxr-xr-x 5 vadikas users 4096  8. 9. 13:56 ..
    lrwxrwxrwx 1 vadikas users    7  8. 9. 11:53 bin -> usr/bin
    -rw-r--r-- 1 vadikas users 2065  8. 9. 17:53 default.nix
    drwxr-xr-x 6 vadikas users 4096  8. 9. 11:53 etc
    drwxr-xr-x 3 vadikas users 4096  8. 9. 11:53 host
    -rw-r--r-- 1 vadikas users 3773  8. 9. 17:51 Makefile   
    -rw-r--r-- 1 vadikas users  371  8. 9. 11:53 shell.nix

 Look into default.nix. It’s more or less straight forward, change the name of the nix package to be associated with your VM here:
   
   stdenvNoCC.mkDerivation {
      name = "spectrum-appvm-myapp";

      src = cleanSourceWith {
        filter = name: _type:
          name != "${toString ./.}/build" &&
          !(hasSuffix ".nix" name);
        src = cleanSource ./.;
      };

Add your nix packages so they’ll be included in the VM.

Look into Makefile. Change the paths your VM will be put on the resulting file system:

    # QEMU_KVM = qemu-system-x86_64 -enable-kvm.
    QEMU_KVM = qemu-kvm
    CLOUD_HYPERVISOR = cloud-hypervisor

    VMM = qemu

    HOST_FILES = host/data/myapp/providers/usb/usbvm
    # you can also add more host files here, 
    # they will appear in VM's directoryon /ext filesystem 

    HOST_BUILD_FILES = \
    	build/host/data/myapp/rootfs.ext4 \
    	build/host/data/myapp/vmlinux
    	...

 Test the changes with make run.
 Makefile has run target so you can test your VM on your development host with 

     [vadikas@nixos:~/spectrumos/spectrum/vm/app/myapp] nix-shell -k -I nixpkgs=../../../nixpkgs-spectrum --run 'make run'
  

That will build and run VM on VMM selected in the Makefile, it can be qemu or cloud-hypervisor, or you can hack it to your taste.
When you re' satisfied with testing on your own host, change the extfs.nix file to include your VM into the SpectrumOS filesystem.

    [vadikas@nixos:~/spectrumos]$ cd spectrum/host/initramfs/
    [vadikas@nixos:~/spectrumos/spectrum/host/initramfs]$

    [vadikas@nixos:~/spectrumos/spectrum/host/initramfs]$ vi extfs.nix

Add code sections to extfs.nix file:
 
 let
      netvm = import ../../vm/sys/net {
        inherit pkgs;
        # inherit (foot) terminfo;
      };

      myapp = import ../../vm/app/myapp {
        inherit pkgs;
        # inherit (foot) terminfo;
      };
      
      ...
      
      
      tar -C ${netvm} -c data | tar -C svc -x
      chmod +w svc/data
      tar -C ${myapp} -c data | tar -C svc -x
      chmod +w svc/data
      
      ...

Build the Spectrum root file system:

   
    [vadikas@nixos:~/spectrumos/spectrum]$ nix-build -I nixpkgs=../nixpkgs-spectrum   img/live

Test your  VM  with spectrum OS:

     
    cd ./spectrum/img/live && nix-shell -I nixpkgs ../../../nixpkgs-spectrum
    make run

That will start qemu with SpectrumOS. 

Tools we have in the runtime. 
Running VMs can be managed with the following commands, available in a host terminal:

    lsvm

    List available VMs, along with whether they are currently running.

    vm-console <name>

    Open a terminal emulator for a VM’s console.

    vm-start <name>

    Start a VM.

    vm-stop <name>

    Stop a VM.

Current restrictions (or features) of Spectrum OS& 
Runtime configuration is very limited. You can’t alter the hardcoded into runvm cloud-hypervisor parameters without changing it’s code.
If you want some nonstandard configuration – you can’t use OS tools to manage it, you’ll probably will make your own, 

