final: prev: {
  krisp-discord = with final; let
    krisp-patcher = writers.writePython3 "discord-krisp-patcher"
      {
        libraries = with python3Packages; [ capstone pyelftools ];
        flakeIgnore = [
          "E501" # line too long (82 > 79 characters)
          "F403" # ‘from module import *’ used; unable to detect undefined names
          "F405" # name may be undefined, or defined from star imports: module
        ];
      }
      (builtins.readFile ./patches/krisp-patcher.py);
  in
  prev.discord.overrideAttrs (old: {
    postFixup = (old.postFixup or "") + ''
      ${findutils}/bin/find "$out/opt/Discord/modules" \
        -name 'discord_krisp.node' -exec ${krisp-patcher} {} \;
    '';

    stageModules = writeShellScript "discord-stage-mine" ''
      store_modules="$1"
      modules_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/discord/${old.version}/modules"

      mkdir -p "$modules_dir"
      for m in "$store_modules"/*; do
        dest="$modules_dir/$(basename "$m")"

        if [ -L "$dest" ]; then
          rm "$dest"
        fi

        ${lib.getExe' rsync "rsync"} -a --checksum --delete "$m/" "$dest"
      done

      chmod -R u+w "$modules_dir"

      echo '${
        builtins.toJSON (lib.mapAttrs (_: mod: { installedVersion = mod; }) old.passthru.moduleVersions)
      }' \
        > "$modules_dir/installed.json"
    '';
  });
}
