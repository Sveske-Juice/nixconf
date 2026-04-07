{
  self,
  inputs,
  ...
}: {
  flake.wrappersModules.tmux = {pkgs, ...}: let
    is_vim =
      pkgs.writeShellScriptBin "is_vim.sh"
      # bash
      ''
        pane_pid=$(tmux display -p "#{pane_pid}")

        [ -z "$pane_pid" ] && exit 1

        # Retrieve all descendant processes of the tmux pane's shell by iterating through the process tree.
        # This includes child processes and their descendants recursively.
        descendants=$(ps -eo pid=,ppid=,stat= | awk -v pid="$pane_pid" #awk'{
          if ($3 !~ /^T/) {
            pid_array[$1]=$2
          }
        } END {
          for (p in pid_array) {
            current_pid = p
            while (current_pid != "" && current_pid != "0") {
              if (current_pid == pid) {
                print p
                break
              }
              current_pid = pid_array[current_pid]
            }
          }
        }')

        if [ -n "$descendants" ]; then

            descendant_pids=$(echo "$descendants" | tr '\n' ',' | sed 's/,$//')

            ps -o args= -p "$descendant_pids" | grep -iqE "(^|/)([gn]?vim?x?)(diff)?"

            if [ $? -eq 0 ]; then
                exit 0
            fi
        fi

        exit 1
      '';
  in {
    config = {
      clock24 = true;
      baseIndex = 1;
      terminal = "screen-256color";
      escapeTime = 0;

      plugins = [
        pkgs.tmuxPlugins.minimal-tmux-status
        pkgs.tmuxPlugins.tmux-sessionx
      ];

      configBefore = ''
        unbind C-b
        set -g prefix C-a
        bind C-a send-prefix

        set -g mouse on

        set -g allow-passthrough on
        set -g set-clipboard on

        bind C-l send-keys 'C-l'

        set-option -g automatic-rename on

        set-option -ga terminal-overrides ",alacritty:Tc"
        set-option -g default-terminal "screen-256color"

        bind-key -n 'C-h' if-shell '${is_vim}/bin/is_vim.sh' 'send-keys C-h' 'select-pane -L'
        bind-key -n 'C-j' if-shell '${is_vim}/bin/is_vim.sh' 'send-keys C-j' 'select-pane -D'
        bind-key -n 'C-k' if-shell '${is_vim}/bin/is_vim.sh' 'send-keys C-k' 'select-pane -U'
        bind-key -n 'C-l' if-shell '${is_vim}/bin/is_vim.sh' 'send-keys C-l' 'select-pane -R'

        bind-key -T copy-mode-vi 'C-h' select-pane -L
        bind-key -T copy-mode-vi 'C-j' select-pane -D
        bind-key -T copy-mode-vi 'C-k' select-pane -U
        bind-key -T copy-mode-vi 'C-l' select-pane -R

        set -g @minimal-tmux-fg "#101010"
        set -g @minimal-tmux-bg "#AAAAAA"

        set -g @sessionx-bind 'o'
      '';
    };
  };

  perSystem = {pkgs, ...}: {
    packages.tmux = inputs.wrapper-modules.wrappers.tmux.wrap {
      inherit pkgs;
      imports = [self.wrappersModules.tmux];
    };
  };
}
