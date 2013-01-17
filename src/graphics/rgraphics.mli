(** Runtime R graphics library. *)

type hist = < breaks : float list R.t ;
              counts : float list R.t ;
              density : float list R.t ;
              mids : float list R.t ;
              xname : string R.t ;
              equidist : bool R.t >
val hist : 
  ?breaks:[`n of int | `l of float list R.t | `m of [`Sturges | `Scott | `FD]] ->
  ?freq:bool ->
  ?include_lowest:bool ->
  ?right:bool ->
  ?main:string -> ?xlab:string -> ?ylab:string ->
  ?xlim:float -> ?ylim:float -> 
  float list R.t -> hist R.t



















