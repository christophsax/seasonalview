eval_or_fail_cl <- function(call, senv){
  if (call[[1]] != "seas"){
    z <- "Only calls to seas() are allowed."
    class(z) <- "try-error"
  } else if (!is_call_save(call)){
    z <- "Call is not save and thus not allowed."
    class(z) <- "try-error"
  } else {
    z <- try(eval(call, envir = senv), silent = TRUE)
  }
  z
}
