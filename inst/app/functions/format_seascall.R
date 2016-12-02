

format_seascall <- function(x){
  stopifnot(inherits(x, "call"))
  if (deparse(x[[1]]) != "seas"){
    stop('format_seascall() can only be applied to calls of the seas()')
  }
  # call in which all arguments are specified by their full names
  x <- match.call(definition = seas, x)
  xl <- as.list(x)
  z <- list()
  for (i in 2:length(xl)){
    z[[i - 1]] <- paste(names(xl)[i], "=", deparse(xl[[i]], width.cutoff = 500))
  }
  argstr <- do.call(paste, c(z, sep = ",\n"))
  z <- paste("seas(", argstr, ")", sep = "\n")
  z
}


# format_spclist <- function(x, lastcall){
#   stopifnot(inherits(x, "spclist"))
#   stopifnot(inherits(lastcall, "call"))

#   xl <- as.list(x)
#   xl['series'] <- NULL

#   z <- list()
#   for (i in 1:length(xl)){
#     if (is.list(xl[[i]])){
#       if (length(xl[[i]]) == 0){
#         z <- c(z, paste0(names(xl)[i], " = ", deparse("")))
#       } else {
#         for (j in 1:length(xl[[i]])){
#           z <- c(z, paste0(names(xl)[i], ".", names(xl[[i]])[j], " = ", deparse((xl[[i]][[j]]))))
#         }
#       }
#     } else {
#       z <- c(z, paste0(names(xl)[i], " = ", xl[[i]]))
#     }
#   }

#   argstr <- do.call(paste, c(z, sep = ",\n"))
#   ans <- paste("seas(", paste0("x = ", lastcall$x, ", "), argstr, ")", sep = "\n")
#   ans
# }



# AddSeriesToCall <- function(cl, series, INSPDATA){
#   SP <- INSPDATA[INSPDATA$long == series, ]

#   lcl <- as.list(cl)

#   # add save arg
#   lcl[[paste0(SP$spec, ".save")]] <- SP$short
  
#   # add requirements if secifed
#   if (SP$requires != ""){
#     rl <- eval(parse(text = paste("list(", SP$requires, ")")))
#     # ignore requirements that are already fulfilled
#     rl <- rl[!names(rl) %in% names(lcl)]
#     if (length(rl) > 0){
#       lcl <- c(lcl, rl)
#     }
#   }

#   as.call(lcl)
# }


