{
  outputs = {}: {
    overlays.default = final: _prev: {
      makeEmacsTwistArchive = final.callPackage ./. {};
    };
  };
}
