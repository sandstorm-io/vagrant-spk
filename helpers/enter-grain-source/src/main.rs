// use std::env;
use std::fs::File;
use std::io::Read;
use std::ptr;
use std::env;

#[macro_use]
extern crate syscall;

fn write(fd: usize, buf: &[u8]) {
    unsafe {
        syscall!(WRITE, fd, buf.as_ptr(), buf.len());
    }
}

fn open_as_fd_or_die(filename: &[u8]) -> usize {
    let o_rdonly = 0u64;
    let no_flags = 0u64;
    unsafe {
        let return_value = syscall!(OPEN, filename.as_ptr(), o_rdonly, no_flags);
        sanity_check_fd(return_value);
        return return_value;
    }
}

fn setns(fd: usize, nstype: usize) {
    unsafe {
        syscall!(SETNS, fd, nstype);
    }
}

fn close(fd: usize) {
    unsafe {
        syscall!(CLOSE, fd);
    }
}

fn sanity_check_fd(fd: usize) {
    // For some reason, syscall!(OPEN) returns usize, but I need to check its output against
    // -1. So I'm going to just check if it's >255.
    if fd > 255 {
        let exit_failure = 1usize;
        write(1, ("Failed to open a needed file. Bailing.\n".as_bytes()));
        unsafe {
            syscall!(EXIT, exit_failure);
        }
    }
}

fn setgroups_zero() {
    // Clears auxilary groups. Probably not necessary, but whatever.
    unsafe {
        syscall!(SETGROUPS, 0);
    }
}

fn fchdir(fd: usize) {
    unsafe {
        syscall!(FCHDIR, fd);
    }
}

fn fork() -> usize {
    unsafe {
        syscall!(FORK)
    }
}

fn wait_all_children() {
    let all_children = -1isize;
    let no_options = 0usize;
    let nullptr = 0usize;
    unsafe {
        syscall!(WAIT4, all_children, no_options, nullptr, nullptr);
    }
}

fn setuid_setgid_1000() {
    // These are the right UID & GID because they are what Sandstorm
    // uses inside the user namespace.
    let one_thousand = 1000usize;
    unsafe {
        syscall!(SETUID, one_thousand);
        syscall!(SETGID, one_thousand);
    }
}

fn execve_bash(envp: std::vec::Vec<*const u8>) {
    let bash_path = "/bin/bash\0".as_bytes();
    let nullargv = 0usize;
    unsafe {
        syscall!(EXECVE, bash_path.as_ptr(), nullargv, envp.as_ptr());
    }
}

fn get_envp(pidStrRef: &str) -> std::vec::Vec<*const u8> {
    // Grab the environ from pid 1048 so that when we execve a shell
    // at the end, we can provide the environment.

    let path = "/proc/".to_string() + pidStrRef + &"/environ".to_string();
    let mut envp: &[*const u8];
    let mut file = match File::open(&path) {
        Err(why) => panic!("couldn't open {}: {}", path, why),
        Ok(mut file) => {
            let mut s = String::new();
            match file.read_to_string(&mut s) {
                Err(why) => panic!("couldn't read {}: {}", path, why),
                Ok(_) => {
                    let mut v: Vec<String> = s.split('\0').map(
                        |x| x.to_string() + "\0").collect();
                    v.push("__terminator".to_string());
                    let all_environ_arguments: Vec<*const u8> = v.iter().map(|x| (
                        if x == "__terminator" { ptr::null() }
                        else { x.as_ptr() }
                        )).collect();
                    return all_environ_arguments;
                }            
            }
        }
    };
}

fn main() {
    let pidStrRef = &env::args().nth(1).expect("Panicking: expected argv to have 2 items.").to_string();
    // Grab the environ from pid 1048 so that when we execve a shell
    // at the end, we can provide the environment.
    let result = get_envp(pidStrRef);

    // let filename: &[u8] = b"/usr/bin/sensors\x00";     // <-- Make c strings like this
    // let argv1: &[u8] = b"/usr/bin/sensors\x00";
    // let argv2: &[u8] = b"-h\x00";
    // let argv: &[int] = [                               // <-- store them in this
    // ::core::intrinsics::transmute(argv1.as_ptr()), // <-- transmuting 
    // ::core::intrinsics::transmute(argv2.as_ptr()),
    // 0                                              // <-- and NULL terminate
    // ];
    // let envp: &[int] = [0];let target_environ 
    write(1,
          ("Attaching to process ID ".to_string() + pidStrRef + &"...\n".to_string()).as_bytes());
    let userns_fd = open_as_fd_or_die(
        ("/proc/".to_string() + pidStrRef + "/ns/user\0").as_bytes());
    let ipc_fd = open_as_fd_or_die(
        ("/proc/".to_string() + pidStrRef + "/ns/ipc\0").as_bytes());
    let uts_fd = open_as_fd_or_die(
        ("/proc/".to_string() + pidStrRef + "/ns/uts\0").as_bytes());
    let net_fd = open_as_fd_or_die(
        ("/proc/".to_string() + pidStrRef + "/ns/net\0").as_bytes());
    let pid_fd = open_as_fd_or_die(
        ("/proc/".to_string() + pidStrRef + "/ns/pid\0").as_bytes());
    let mnt_fd = open_as_fd_or_die(
        ("/proc/".to_string() + pidStrRef + "/ns/mnt\0").as_bytes());
    let cwd_fd = open_as_fd_or_die(
        ("/proc/".to_string() + pidStrRef + "/cwd\0").as_bytes());
    setgroups_zero();
    setns(userns_fd, 0x10000000usize); // CLONE_NEWUSER
    close(userns_fd);
    setns(ipc_fd, 0x08000000usize); // CLONE_NEWIPC
    close(ipc_fd);
    setns(uts_fd, 0x04000000usize); // CLONE_NEWUTS
    close(uts_fd);
    setns(net_fd, 0x40000000usize); // CLONE_NEWNET
    close(net_fd);
    setns(pid_fd, 0x20000000usize); // CLONE_NEWPID
    close(pid_fd);
    setns(mnt_fd, 0x00020000usize); // CLONE_NEWNS which I guess is mount namespaces
    close(mnt_fd);
    fchdir(cwd_fd);
    close(9);
    // fork, and do a handful of things in the child before we execve bash.
    let fork_result = fork();
    if fork_result == 0 {
        // in the child
        setuid_setgid_1000();
        write(1, "About to start shell...\n\0".as_bytes());
        execve_bash(result);
    } else {
        // in the parent
        wait_all_children();
    }
}

// open("/proc/1048/ns/user", O_RDONLY)    = 3
// open("/proc/1048/ns/ipc", O_RDONLY)     = 4
// open("/proc/1048/ns/uts", O_RDONLY)     = 5
// open("/proc/1048/ns/net", O_RDONLY)     = 6
// open("/proc/1048/ns/pid", O_RDONLY)     = 7
// open("/proc/1048/ns/mnt", O_RDONLY)     = 8
// open("/proc/1048/cwd", O_RDONLY)        = 9
// setgroups(0, [])                        = 0
// setns(3, CLONE_NEWUSER)                 = 0
// close(3)                                = 0
// setns(4, CLONE_NEWIPC)                  = 0
// close(4)                                = 0
// setns(5, CLONE_NEWUTS)                  = 0
// close(5)                                = 0
// setns(6, CLONE_NEWNET)                  = 0
// close(6)                                = 0
// setns(7, CLONE_NEWPID)                  = 0
// close(7)                                = 0
// setns(8, CLONE_NEWNS)                   = 0
// close(8)                                = 0
// fchdir(9)                               = 0
// close(9)                                = 0
