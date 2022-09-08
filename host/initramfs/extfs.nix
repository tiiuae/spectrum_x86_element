# SPDX-FileCopyrightText: 2021-2022 Alyssa Ross <hi@alyssa.is>
# SPDX-License-Identifier: MIT

{ pkgs, runCommand, tar2ext4 }:

let
  netvm = import ../../vm/sys/net {
    inherit pkgs;
    # inherit (foot) terminfo;
  };

  usbvm = import ../../vm/sys/usb {
    inherit pkgs;
    # inherit (foot) terminfo;
  };

  appvm-catgirl = import ../../vm/app/catgirl {
    inherit pkgs;
    # inherit (foot) terminfo;
  };

  appvm-lynx = import ../../vm/app/lynx {
    inherit pkgs;
    # inherit (foot) terminfo;
  };

  appvm-usbapp = import ../../vm/app/usbapp {
    inherit pkgs;
    # inherit (foot) terminfo;
  };
in

runCommand "ext.ext4" {
  nativeBuildInputs = [ tar2ext4 ];
} ''
  mkdir svc

  tar -C ${netvm} -c data | tar -C svc -x
  chmod +w svc/data
  tar -C ${usbvm} -c data | tar -C svc -x
  chmod +w svc/data
  tar -C ${appvm-catgirl} -c data | tar -C svc -x
  chmod +w svc/data
  tar -C ${appvm-lynx} -c data | tar -C svc -x
  chmod +w svc/data
  tar -C ${appvm-usbapp} -c data | tar -C svc -x
  chmod +w svc/data

  tar -cf ext.tar svc
  tar2ext4 -i ext.tar -o $out
''
