{ config, lib, pkgs, ... }:

{
  powerManagement.cpuFreqGovernor = "performance";

  #
  # LIMITS (man limits.conf)
  #
  # https://wiki.archlinux.org/title/Limits.conf
  # 
  # Check system limits: 
  # - ulimit -a
  # Check the maximum of file descriptors
  # - ulimit -Hn
  # - cat /proc/sys/fs/file-max (for system wide)
  # - cat /proc/sys/fs/nr_open (for system wide)
  # Check number of process per user:
  # - ps h -LA -o user | sort | uniq -c | sort -n
  # 
  security.pam.loginLimits = [
    # maximum nice priority allowed to raise to [-20,19] (negative values boost process priority)
    #
    # The 'nice' value should do the same as 'rtprio' but for standard CFQ scheduling
    # It sets the initial process spawned when PAM is setting these limits to that nice vaule, 
    # a normal user can then go to that nice level or higher without needing root to set them [1]
    #
    # The current Linux scheduler gives a program at -1 twice as much CPU power as 
    # a 0, and a program at -2 twice as much as a -1, and so forth. This means that 0.9999046% 
    # of your CPU time will go to the program that's at -20, but some small fraction does go 
    # to the program at 0. The program at 0 will feel like it's running on a 200kHz processor![2][3]
    { domain = "root"; type = "-"; item = "nice"; value = "-20"; }
    # Do not set -20, as the root needs it to be able to fix an unresponsive system[1]
    # TEST: max value with nice --11 echo 1
    { domain = "@users"; type = "-"; item = "nice"; value = "-5"; }
    { domain = "@audio"; type = "-"; item = "nice"; value = "-19"; }

    # the priority to run user process with [-20,19] (negative values boost process priority)
    { domain = "@users"; type = "soft"; item = "priority"; value = "0"; }
    { domain = "@audio"; type = "soft"; item = "priority"; value = "-10"; }

    # Realtime configs
    # Check max with: schedtool -r
    # Check current with: ulimit -a
    { domain = "@users"; type = "-"; item = "rtprio"; value = "10"; }
    { domain = "@audio"; type = "-"; item = "rtprio"; value = "99"; }

    # Number of file descriptors any process owned by the specified domain 
    # can have open at any one time.
    #
    # Certain games needs this value as hight as 8192, or in case of lutris with esync, >=524288 [4][5],
    # but setting this value too high or to unlimited may break some tools like fakeroot [6]
    { domain = "*"; type = "hard"; item = "nofile"; value = "1048576"; } # recommended by esync [5]
    { domain = "*"; type = "soft"; item = "nofile"; value = "8192"; } # default 1024
    { domain = "@audio"; type = "soft"; item = "nofile"; value = "65536"; }

    # Memory locked memory is never swappable and remains resident. This value is strictly 
    # controlled because it can be abused by people to starve a system of memory and cause swapping [1]
    { domain = "@audio"; type = "-"; item = "memlock"; value = "524288"; } # default 8192

    # NOTE FOR GAMING:
    # SCHED_ISO was designed to give users a SCHED_RR-similar class. 
    # To quote Con Kolivas: "This is a non-expiring scheduler policy designed to guarantee 
    # a timeslice within a reasonable latency while preventing starvation. Good for gaming, 
    # video at the limits of hardware, video capture etc."
    # 
    # SCHED_ISO is now somewhat deprecated; SCHED_RR is now possible for normal users,
    # albeit to a limited amount only. See newer kernels. (from `man schedtool`)


    # As a short mnemonic rule, each 'F' denotes a set of 4 CPUs
    # (0xF: all 4 CPUs, 0xFF: all 8 CPUs, and so on ...)
    # schedtool -
    # schedtool -a 0,1 -n -10 -e
    # schedtool -a 0xFF -n -10 -e (each F is 4 CPUs)
  ];
  # [1] - https://serverfault.com/questions/487602/linux-etc-security-limits-conf-explanation
  # [2] - https://wiki.archlinux.org/title/Limits.conf#nice
  # [3] - https://unix.stackexchange.com/questions/334170/is-changing-the-priority-of-a-games-process-to-realtime-bad-for-the-cpu
  # [4] - https://github.com/lutris/docs/blob/master/HowToEsync.md
  # [5] - https://github.com/zfigura/wine/blob/esync/README.esync
  # [6] - https://wiki.archlinux.org/title/Limits.conf#nofile
}
