# Git hosting and control suite

## Custom commands supported:

 * `help` - Print this help text.
 * `init <group>/<repo>[.git] [Description]` - Initialize new Git repository.
 * `list` - List available repositories.
 * `list-commands` - List available commands

## Required runtime configuration

### In system:

 * Configure `git` user's shell to be git-shell.
 * Configure pam_umask with sane umask.
 * Configure sufficiently restrictive permissions on git $HOME directory.

### In `/etc/ssh/sshd_config`:

See `~/.config/config.sshd`.

### In `~/.config/git-shell-commands`:

 * `GIT_HOST=git.example.org` - Self-reference address to be used by init and list commands to refer to the repo.
 * `GIT_ADM_GROUP="Git Admins"` - System (NSS/AD/etc.) group given permissions to manage Git installation.

### In `~/.ssh/authorized_keys`:

Prefix keys with `environment="GIT_USER=username" key-type key…`. The `GIT_USER` should be system user's name.
It is only used in management scripts, thus not strictly required for normal Git operations.
