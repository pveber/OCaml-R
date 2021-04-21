module C = Configurator.V1
module S = String

let trim_to_list str =
  match S.trim str with
  | "" -> []
  | str -> S.split_on_char ' ' str

let cfig c =
  let default: C.Pkg_config.package_conf = {
      libs = ["-lR"; "-lRmath"];
      cflags = [] }
  in
  let rlib = C.Process.run c "pkg-config" ["--libs-only-L"; "--libs-only-l"; "libR"; "libRmath"] in
  let rflg = C.Process.run c "pkg-config" ["--cflags"; "libR"; "libRmath"] in
  let chk = (rlib.exit_code, rflg.exit_code) in
  let lib = trim_to_list rlib.stdout in
  let flg = trim_to_list rflg.stdout in  
  let discover: C.Pkg_config.package_conf = {
      libs = lib;
      cflags = flg }
  in
  let conf =
    match chk with
    | (0, 0) -> discover
    | _ -> default
  in
  C.Flags.write_sexp "c_flags.sexp" conf.cflags;
  C.Flags.write_sexp "c_library_flags.sexp" conf.libs;;

C.main ~name:"OCaml-R" cfig;;
