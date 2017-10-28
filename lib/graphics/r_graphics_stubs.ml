open OCaml_R

let () = ignore (R.eval_string "require(graphics, quietly=TRUE)")

let id x = x

module Symbol = struct

  let plot = R.symbol ~generic:true "plot"
  let par = R.symbol "par"

end

let plot ?main ?xlab ?ylab ?xlim ?ylim ?y x =
  R.eval Symbol.plot [
    R.arg id x ;
    R.opt id "y" y ;
    R.opt id "main" main ;
    R.opt id "xlab" xlab ;
    R.opt id "ylab" ylab ;
    R.opt id "xlim" xlim ;
    R.opt id "ylim" ylim ;
  ]

let plot2
 ?main ?xlab ?ylab ?xlim ?ylim x y =
  R.eval Symbol.plot [
    R.arg id x ;
    R.arg id y ;
    R.opt id "main" main ;
    R.opt id "xlab" xlab ;
    R.opt id "ylab" ylab ;
    R.opt id "xlim" xlim ;
    R.opt id "ylim" ylim ;
  ]

let par ?mfrow () =
  R.eval Symbol.par [
    R.opt id "mfrow" mfrow ;
  ]
