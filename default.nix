{
  runCommand,
  gnumake,
  writeShellApplication,
}: {
  # To build an archive with `nix run` command, it is recommended to set this
  # name
  name ? "emacs-config-archive-builder",
  earlyInitFile ? null,
  narName ? "archive.nar",
  outName ? "archive.tar.zstd",
}: emacs-env: let
  inherit (builtins) concatStringsSep;

  initFile = runCommand "init.el" {} ''
    mkdir -p $out
    touch $out/init.el
    for file in ${concatStringsSep " " emacs-env.initFiles}
    do
      cat "$file" >> $out/init.el
      echo >> $out/init.el
    done
  '';

  share = runCommand "emacs-init-files" {} ''
    mkdir -p $out/share/emacs
    ${
      lib.optionalString (earlyInitFile != null)
      "install ${earlyInitFile} $out/share/emacs/early-init.el"
    }
    install -t $out/share/emacs ${initFile}/init.el
  '';
in
  writeShellApplication {
    inherit name;
    runtimeInputs = [
      gnumake
    ];
    text = ''
      files=files.txt
      archive="${narName}"
      out="${outName}"

      set -x

      echo > "$files" "${concatStringsSep "\n" [
        emacs-env
        share
      ]}"

      xargs nix-store -qR < "$files" \
        | xargs nix-store --export > "$archive"

      tar cf - "$archive" "$files" | zstd > "$out"
    '';
  }
