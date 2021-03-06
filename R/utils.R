#IDEA: create a function to make every part of the genome not covered by  the segments, a 2n segment. Do NOT call it from here automagically.

#################### Selection of columns #########################
#' getColumn
#'
#' @description
#' Use simple pattern matching to try to identify a column in a data.frame or
#' equivalent by its name
#'
#' @details
#' This function will use pattern matching to try to identify which column of
#' a data.frame contains a certain data. It will return its number. If
#' \code{col} is specified it will not use pattern matching but identify
#' if a column with that exact name exists and return its position.
#'
#'
#' @usage getColumn(df, col=NULL, pattern="", avoid.pattern = NULL, msg.col.name="", needed=TRUE, verbose = TRUE)
#'
#' @param df (data.frame or equivalent) The object were columns are searched. It must be either a data.frame or an object where names(df) works.
#' @param col (number or character) The column to identify. If NULL an heuristic will be used to automatically identify the column. It can also a number or a character to define the exact column to return.(defaults to NULL)
#' @param pattern (character) The pattern to match the column name. If more than one column matches the pattern, the first one (leftmost) will be returned. The pattern may be any valid regular expression. (defaults to "")
#' @param avoid.pattern (character) The pattern to avoid on the column name. The pattern may be any valid regular expression. (defaults to "")
#' @param msg.col.name (character) Only used in the error message to make the message clearer. The name of the column we are searching for. (defaults to "")
#' @param needed (logical) Whether the column is needed or not. If TRUE, an error will be raised if the column is not found. (defaults to TRUE)
#' @param verbose (logical) Whether to show information messages. (defaults to TRUE)
#'
#' @return
#' The number of the column matching the specification or NULL if no column was found.
#'
#' @examples
#'
#' df <- data.frame("id"= "rs1234", "endogenous" = FALSE, "chromosome"="chr1", "Start"=0, "end.position"=100,
#' "copy.number.level"=3, "LOH"=0, "median.value.per.segment"=1.2,
#' "BAF"=0.2, "Log Ratio"=1.5,  "strange.name"="strange.value")
#'
#' col.num <- getColumn(df = df, pattern = "Chr|chr",  msg.col.name = "Chromosome", needed = TRUE)
#' col.num <- getColumn(df = df, col = "chromosome",  msg.col.name = "Chromosome", needed = TRUE)
#' col.num <- getColumn(df = df, col = 3, msg.col.name = "Chromosome", needed = TRUE)
#'
#'
#' col.num <- getColumn(df = df, pattern = "end",  msg.col.name = "End", needed = TRUE)
#' col.num <- getColumn(df = df, pattern = "end", avoid.pattern = "endogenous", msg.col.name = "End", needed = TRUE)
#'
#' @export getColumn


getColumn <- function(df, col = NULL, pattern = NULL, avoid.pattern = NULL, msg.col.name = "", needed=TRUE, verbose = TRUE){
  # Check parameters
  # df must be an object which accepts names function
  col.names <- tryCatch(names(df), error = function(e) stop("df must be an object with 'names' (i.e. data.frame, DataFrame...)"))

  # If col is not NULL and is a character or numeric, col must have length 1
  if(!is.null(col)) {
    if (is.character(col)| is.numeric(col)){
      if(length(col)!=1){
        stop("col parameter must be either NULL, a character of length 1 or a integer of length 1")
      }
      if(is.numeric(col)){
        if(col == round(col)){
          col <- as.integer(col)
        } else {
          stop("If col is numeric it must be an integer")
        }
        
        if(col < 1 || col > length(col.names)){
          stop("col must be a single integer between one and length of names of df")
        }
      }
   
    }else{
      stop("col parameter must be either NULL, a character of length 1 or a integer of length 1")
    }
  }

  # msg.col.name must be a character
  if(is.null(msg.col.name)){
    msg.col.name <- ""
  }
  if(!is.character(msg.col.name)){
    stop("msg.col.name must be a character")
  }

  # Needed must be a logical
  if(!is.logical(needed)){
    stop("needed must be a logical")
  }

  #END check parameters

  if(is.numeric(col)){
    return(col)
  }
  
  #Now we assume col is a character or NULL
  
  
  if(is.null(col.names)){
    stop("col.names cannot be NULL if we look for a pattern or column name.")
  }
  
  
  col.num <- integer(0)
  if(is.null(col)) {
    if(is.null(pattern)){
      stop("Either col or pattern must be provided")

    } else{
      if(is.null(avoid.pattern) || is.na(avoid.pattern)){
        col.num <- which(grepl(col.names, pattern = pattern, ignore.case = TRUE))[1]
      }else{
        col.num <- which(!grepl(col.names, pattern = avoid.pattern, ignore.case = TRUE) &
                           grepl(col.names, pattern = pattern, ignore.case = TRUE))[1]
      }
    }

  } else {
    if(is.numeric(col)) {
      col.num <- col
    } else {
      if(is.character(col))  {
        col.num <- which(col.names==col)
      }
    }
  }
  if(is.na(col.num) || length(col.num)==0) {
    if(needed==TRUE) {
      stop("The column ", msg.col.name, " was not found in the data")
    } else {
      col.num <- NULL
    }
  }

  if(verbose == TRUE & !is.null(col.num)){
    if (nchar(msg.col.name)>0){
      message("The column identified as ", msg.col.name," is: ", col.names[col.num])
    }else{
      message("The column identified is: ", col.names[col.num])
    }
    
  } 

  return(col.num)
}


#' getChrColumn
#'
#' @description
#' Identify the column in a data.frame or equivalent with the chromosome information
#'
#' @details
#' Identify the column of a data.frame or equivalent that contains the chromosome
#' information and return its position
#'
#' @usage getChrColumn(df, col=NULL, avoid.pattern = NULL, needed=TRUE, verbose = TRUE)
#'
#' @param df (data.frame or equivalent) The object were columns are searched. It must be either a data.frame or an object where names(df) works.
#' @param col (number or character) The column to identify. If NULL an heuristic will be used to automatically identify the column. It can also a number or a character to define the exact column to return.(defaults to NULL)
#' @param needed (logical) Whether the column is needed or not. If TRUE, an error will be raised if the column is not found. (defaults to TRUE)
#' @param avoid.pattern (character) An optional pattern to avoid on the column name. The pattern may be any valid regular expression. (defaults to "")
#' @param verbose Whether to show information messages. (defaults to TRUE)
#'
#' @return
#' The number of the column matching the specification or NULL if no column was found.
#'
#' @examples
#' df <- data.frame("id"= "rs1234","chromosome"="chr1", "Start"=0, "end.position"=100,
#' "copy.number.level"=3, "LOH"=0, "median.value.per.segment"=1.2,
#' "BAF"=0.2, "Log Ratio"=1.5, "strange.name"="strange.value")
#' col.num <- getChrColumn(df = df)
#' col.num <- getChrColumn(df = df, col = "chromosome")
#'
#' @export getChrColumn
getChrColumn <- function(df, col = NULL, avoid.pattern = NULL, needed = TRUE, verbose = TRUE) {
  return(getColumn(df, col=col, pattern="chr|seqnames",  avoid.pattern = avoid.pattern, msg.col.name="Chromosome", needed=needed, verbose = verbose))
}

#' getPosColumn
#'
#' @description
#' Identify the column in a data.frame or equivalent with the position information
#'
#' @details
#' Identify the column of a data.frame or equivalent that contains the position
#' information and return its position
#'
#' @usage getPosColumn(df, col = NULL, avoid.pattern = NULL, needed = TRUE, verbose = TRUE)
#'
#' @inheritParams getChrColumn
#'
#' @return
#' The number of the column matching the specification or NULL if no column was found.
#'
#' @examples
#'
#' df <- data.frame("id"= "rs1234","chromosome"="chr1", "Start"=0, "end.position"=100,
#' "copy.number.level"=3, "LOH"=0, "median.value.per.segment"=1.2,
#' "BAF"=0.2, "Log Ratio"=1.5, "strange.name"="strange.value")
#' col.num <- getPosColumn(df = df)
#' col.num <- getPosColumn(df = df, col = "strange.name")
#'
#' @export getPosColumn
#'
getPosColumn <- function(df, col = NULL, avoid.pattern = NULL, needed = TRUE, verbose = TRUE) {
  return(getColumn(df, col=col, pattern="Position|pos|loc|maploc", avoid.pattern = avoid.pattern, msg.col.name = "Position", needed=needed, verbose = verbose))
}

#' getStartColumn
#'
#' @description
#' Identify the column in a data.frame with the start position information
#'
#' @details
#' Identify the column of a data.frame that contains the position
#' information and return its position
#'
#' @usage getStartColumn(df, col = NULL, avoid.pattern = NULL, needed = TRUE, verbose = TRUE)
#'
#' @inheritParams getChrColumn
#'
#' @return
#' The number of the column matching the specification or NULL if no column was found.
#'
#' @examples
#' df <- data.frame("id"= "rs1234","chromosome"="chr1", "Start"=0, "end.position"=100,
#' "copy.number.level"=3, "LOH"=0, "median.value.per.segment"=1.2,
#' "BAF"=0.2, "Log Ratio"=1.5, "strange.name"="strange.value")
#' col.num <- getStartColumn(df = df )
#' col.num <- getStartColumn(df = df, col = "Start")
#'
#' @export getStartColumn
getStartColumn <- function(df, col=NULL, avoid.pattern = NULL, needed = TRUE, verbose = TRUE) {
  return(getColumn(df, col=col, pattern="start|first|begin", avoid.pattern = avoid.pattern, msg.col.name = "Start", needed=needed, verbose = verbose))
}

#' getEndColumn
#'
#' @description
#' Identify the column in a data.frame or equivalent with the end position information
#'
#' @details
#' Identify the column of a data.frame or equivalent that contains the position
#' information and return its position
#'
#' @usage getEndColumn(df, col = NULL, avoid.pattern = NULL, needed = TRUE, verbose = TRUE)
#'
#' @inheritParams getChrColumn
#'
#' @return
#' The number of the column matching the specification or NULL if no column was found.
#'
#' @examples
#'
#' df <- data.frame("id"= "rs1234","chromosome"="chr1", "Start"=0, "end.position"=100,
#' "copy.number.level"=3, "LOH"=0, "median.value.per.segment"=1.2,
#' "BAF"=0.2, "Log Ratio"=1.5, "strange.name"="strange.value")
#' col.num <- getEndColumn(df = df)
#' col.num <- getEndColumn(df = df, col = "end.position")
#'
#' @export getEndColumn
#'
getEndColumn <- function(df, col=NULL, avoid.pattern = NULL, needed = TRUE, verbose = TRUE) {
  return(getColumn(df, col=col, pattern="end|last", avoid.pattern = avoid.pattern, msg.col.name = "End", needed=needed, verbose = verbose))
}


#' getCopyNumberColumn
#'
#' @description
#' Identify the column in a data.frame or equivalent with the copy number information
#'
#' @details
#' Identify the column of a data.frame or equivalent that contains the copy number
#' information and return its position
#'
#' @usage getCopyNumberColumn(df, col = NULL, avoid.pattern = NULL, needed = TRUE, verbose = TRUE)
#'
#' @inheritParams getChrColumn
#'
#' @return
#' The number of the column matching the specification or NULL if no column was found.
#'
#' @examples
#'
#' df <- data.frame("id"= "rs1234","chromosome"="chr1", "Start"=0, "end.position"=100,
#' "copy.number.level"=3, "LOH"=0, "median.value.per.segment"=1.2,
#' "BAF"=0.2, "Log Ratio"=1.5, "strange.name"="strange.value")
#' col.num <- getCopyNumberColumn(df = df)
#' col.num <- getCopyNumberColumn(df = df, col = "copy.number.level")
#'
#' @export getCopyNumberColumn
getCopyNumberColumn <- function(df, col = NULL, avoid.pattern = NULL, needed = TRUE, verbose = TRUE) {
  return(getColumn(df, col = col, pattern = "cn|copy",  avoid.pattern = avoid.pattern, msg.col.name = "Copy Number", needed = needed, verbose = verbose))
}

#' getLOHColumn
#'
#' @description
#' Identify the column in a data.frame or equivalent with LOH information
#'
#' @details
#' Identify the column of a data.frame or equivalent that contains the LOH
#' information and return its position
#'
#' @usage getLOHColumn(df, col = NULL, avoid.pattern = NULL, needed = TRUE, verbose = TRUE)
#'
#' @inheritParams getChrColumn
#'
#' @return
#' The number of the column matching the specification or NULL if no column was found.
#'
#' @examples
#'
#' df <- data.frame("id"= "rs1234","chromosome"="chr1", "Start"=0, "end.position"=100,
#' "copy.number.level"=3, "LOH"=0, "median.value.per.segment"=1.2,
#' "BAF"=0.2, "Log Ratio"=1.5, "strange.name"="strange.value")
#' col.num <- getLOHColumn(df = df)
#' col.num <- getLOHColumn(df = df, col = "LOH")
#'
#' @export getLOHColumn
getLOHColumn <- function(df, col = NULL, avoid.pattern = NULL, needed = TRUE, verbose = TRUE) {
  return(getColumn(df, col=col, pattern="loh|loss",  avoid.pattern = avoid.pattern, msg.col.name = "LOH", needed=needed, verbose = verbose))
}

#' getSegmentValueColumn
#'
#' @description
#' Identify the column in a data.frame or equivalent with the position of
#' the segment value information.
#'
#' @details
#' Identify the column of a data.frame or equivalent that contains the segment
#' information and return its position.
#'
#' @usage getSegmentValueColumn(df, col = NULL, avoid.pattern = NULL, needed = TRUE, verbose = TRUE)
#'
#' @inheritParams getChrColumn
#'
#' @return
#' The number of the column matching the specification or NULL if no column was found.
#'
#' @examples
#'
#' df <- data.frame("id"= "rs1234","chromosome"="chr1", "Start"=0, "end.position"=100,
#' "copy.number.level"=3, "LOH"=0, "median.value.per.segment"=1.2,
#' "BAF"=0.2, "Log Ratio"=1.5, "strange.name"="strange.value")
#' col.num <- getSegmentValueColumn(df = df)
#' col.num <- getSegmentValueColumn(df = df, col = "median.value.per.segment")
#'
#' @export getSegmentValueColumn
#'
getSegmentValueColumn <- function(df, col = NULL, avoid.pattern = NULL, needed = TRUE, verbose = TRUE) {
  return(getColumn(df, col=col, pattern="value|mean|median|ratio", avoid.pattern = avoid.pattern, msg.col.name = "Segment Value", needed=needed, verbose = verbose))
}


#' getBAFColumn
#'
#' @description
#' Identify the column in a data.frame or equivalent with the B-allele frecuency information
#'
#' @details
#' Identify the column of a data.frame or equivalent that contains the bi-allelic frecuency
#' information and return its position
#'
#' @usage getBAFColumn(df, col = NULL, avoid.pattern = NULL, needed = TRUE, verbose = TRUE)
#'
#' @inheritParams getChrColumn
#'
#' @return
#' The number of the column matching the specification or NULL if no column was found.
#'
#' @examples
#'
#' df <- data.frame("id"= "rs1234","chromosome"="chr1", "Start"=0, "end.position"=100,
#' "copy.number.level"=3, "LOH"=0, "median.value.per.segment"=1.2,
#' "BAF"=0.2, "Log Ratio"=1.5, "strange.name"="strange.value")
#' col.num <- getBAFColumn(df = df)
#' col.num <- getBAFColumn(df = df, col = "BAF")
#'
#' @export getBAFColumn

getBAFColumn <- function(df, col = NULL, avoid.pattern = NULL, needed = TRUE, verbose = TRUE){
  return(getColumn(df, col = col, pattern = "BAF|B.Allele|freq", avoid.pattern = avoid.pattern, msg.col.name = "B-Allele Frequency", needed = needed, verbose = verbose))
}

#' getLRRColumn
#'
#' @description
#' Identify the column in a data.frame or equivalent with the Log Ratio information
#'
#' @details
#' Identify the column of a data.frame or equivalent that contains the Log Ratio
#' information and return its position
#'
#' @usage getLRRColumn(df, col = NULL, avoid.pattern = NULL, needed = TRUE, verbose = TRUE)
#'
#' @inheritParams getChrColumn
#'
#' @return
#' The number of the column matching the specification or NULL if no column was found.
#'
#' @examples
#'
#' df <- data.frame("id"= "rs1234","chromosome"="chr1", "Start"=0, "end.position"=100,
#' "copy.number.level"=3, "LOH"=0, "median.value.per.segment"=1.2,
#' "BAF"=0.2, "Log Ratio"=1.5, "strange.name"="strange.value")
#'  col.num <- getLRRColumn(df = df)
#'  col.num <- getLRRColumn(df = df, col = "Log.Ratio")
#'
#' @export getLRRColumn
#'
getLRRColumn <- function(df, col = NULL, avoid.pattern = NULL, needed = TRUE, verbose = TRUE){
  return(getColumn(df, col = col, pattern = "LRR|Log.R.Ratio|Log", avoid.pattern = avoid.pattern, msg.col.name = "Log Ratio", needed = needed, verbose = verbose))
}


#' getIDColumn
#'
#' @description
#' Identify the column in a data.frame or equivalent with the ID information
#'
#' @details
#' Identify the column of a data.frame or equivalent that contains ID
#' information and return its position
#'
#' @usage getIDColumn(df, col = NULL, avoid.pattern = NULL, needed = TRUE, verbose = TRUE)
#'
#' @inheritParams getChrColumn
#'
#' @return
#' The number of the column matching the specification or NULL if no column was found.
#'
#' @examples
#'
#' df <- data.frame("id"= "rs1234","chromosome"="chr1", "Start"=0, "end.position"=100,
#' "copy.number.level"=3, "LOH"=0, "median.value.per.segment"=1.2,
#' "BAF"=0.2, "Log Ratio"=1.5, "strange.name"="strange.value")
#'  col.num <- getIDColumn(df = df)
#'  col.num <- getIDColumn(df = df, col = "id")
#'
#' @export getIDColumn

getIDColumn <- function(df, col = NULL, avoid.pattern = NULL, needed = TRUE, verbose =TRUE){
  return(getColumn(df, col = col, pattern = "name|id|snp|sampleName", avoid.pattern = avoid.pattern, msg.col.name = "Identifier", needed = needed, verbose = verbose))
}



#######################################Transform Chromosomes ########################################################

#' transformChr
#'
#' @description
#' Transformation of the chromosomes
#'
#' @details
#' This function will transform the name of the chormosomes, according to the
#' parameter chr.transformation. This is useful in situations were files,
#' such as .seg files as the ones generated by CNVkit, have the chromosome names
#' as numbers. In order to transform the sexual and mitocondrial chromosomes
#' from numbers back to characters, we can use this function.
#' The exact transformation might be provided as described at
#' https://cnvkit.readthedocs.io/en/stable/importexport.html#import-seg,
#' (e.g. "key:value")
#'
#' @usage transformChr(chr, chr.transformation = "23:X,24:Y,25:MT")
#'
#' @param chr (character) The chromosome names to transform
#' @param chr.transformation (character) The transformation of the chromosomes
#' names in a comma separated "key:value" format.(defaults to "23:X,24:Y,25:MT")
#'
#' @return
#' A character vector where the name of the chromosomes have been changed
#' according to chr.transformation parameter.
#'
#' @examples
#' seg.file <- system.file("extdata", "DNACopy_output.seg", package = "CopyNumberPlots", mustWork = TRUE)
#' seg.data <- read.table(file = seg.file, sep = "\t", skip = 1, stringsAsFactors = FALSE)
#' colnames(seg.data) <-  c("ID", "chrom", "loc.start", "loc.end", "num.mark", "seg.mean")
#'
#' # here we have the name of the chromosomes in a number format and how many segments are in each one.
#' table(seg.data$chrom)
#'
#' # by this way we have the name 23 and 24 respectively transformed to X and Y.
#' seg.data$chrom <- transformChr(chr = seg.data$chrom, chr.transformation ="23:X,24:Y,25:MT")
#' table(seg.data$chrom)
#'
#' @export transformChr
#'
transformChr <- function(chr, chr.transformation = "23:X,24:Y,25:MT"){
  if(!is.null(chr.transformation)){
    
    if(is.character(chr.transformation)){
      
      if(nchar(chr.transformation) == 0){
        stop("chr.transformation parameter must be a character \"key:value\" of length one")
      }
      
    } else{
      stop("chr.transformation must be a character")
    }
  } else {
    stop("chr.transformation parameter must be a character \"key:value\" of length one")
  }
  
  chr.transformation <- unlist(strsplit(x = chr.transformation, split = ","))
  chr.transformation <- do.call(rbind,strsplit(x = chr.transformation, split = ":"))
  chr.trans <- chr.transformation[,2]
  names(chr.trans) <- chr.transformation[,1]

  for(i in seq_len(length(chr.trans))){
    chr[which(chr == names(chr.trans)[i])] <- chr.trans[i]
  }
  return(chr)
}

#################################### Remove NA values of snp.data ###################################
#' removeNAs
#'
#' @description
#' Removing NA from snp data.
#'
#' @details
#' This function will remove rows with NA values in snp data. We can decide
#' which columns we take into account to detect NAs, using the lrr.na, baf.na
#' and id.na parameters.
#'
#' @usage removeNAs(snp.data, lrr.na = TRUE, baf.na = TRUE, id.na = TRUE, verbose = TRUE)
#'
#' @param snp.data (GRanges, GRangesList or list) A GRanges, GRangesList or a list of GRanges.
#' @param lrr.na (logical) Whether to remove the rows that have NAs in  the lrr column. (defaults to TRUE)
#' @param baf.na (logical) Whether to remove the rows that have NAs in  the baf column. (defaults to TRUE)
#' @param id.na (logical) Whether to remove the rows that have NAs in  the id column. (defaults to TRUE)
#' @param verbose (logical) Whether to show information messages. (defaults to TRUE)
#'
#' @return
#' A GRanges or a list of GRanges where the NA values have been removed.
#'
#' @examples
#' #GRanges
#' seg.data <- regioneR::toGRanges(data.frame(chr = c("chr1", "chr1", "chr2", "chr5"), start = c(0,50000,8014630,14523572), end = c(48953, 7023664,9216331,153245687), lrr = c(NA,0.25,1.5,NA)))
#' seg.data <- removeNAs(snp.data = seg.data)
#'
#' #List of GRanges
#' seg.data <- list(a = regioneR::toGRanges(data.frame(chr = c("chr1", "chr1", "chr2", "chr5"), start = c(0,50000,8014630,14523572), end = c(48953, 7023664,9216331,153245687), lrr = c(NA,0.25,1.5,NA),baf = c(1.5,2.5,NA,6), id = c("rs52456","rs52457","rs52458","rs52459"))),
#'                     b=regioneR::toGRanges(data.frame(chr = c("chr1", "chr1", "chr2", "chr5"), start = c(0,50000,8014630,14523572), end = c(48953, 7023664,9216331,153245687), lrr = c(2.5,NA,1.5,0.25), baf = c(1.5,2.5,NA,6), id = c("rs52456","rs52457","rs52458","rs52459"))))
#' seg.data <- removeNAs(snp.data = seg.data)
#'
#' #GRangesList
#' seg.data <- GRangesList(a = regioneR::toGRanges(data.frame(chr = c("chr1", "chr1", "chr2", "chr5"), start = c(0,50000,8014630,14523572), end = c(48953, 7023664,9216331,153245687), lrr = c(NA,0.25,1.5,NA), baf = c(1.5,2.5,NA,6), id = c("rs52456","rs52457","rs52458","rs52459"))), b=regioneR::toGRanges(data.frame(chr = c("chr1", "chr1", "chr2", "chr5"), start = c(0,50000,8014630,14523572), end = c(48953, 7023664,9216331,153245687), lrr = c(2.5,NA,1.5,0.25), baf = c(1.5,2.5,NA,6), id = c("rs52456","rs52457","rs52458","rs52459"))))
#' seg.data <- removeNAs(snp.data = seg.data)
#'
#'
#' @export removeNAs
#'
#'
removeNAs <- function(snp.data, lrr.na = TRUE, baf.na = TRUE, id.na = TRUE, verbose = TRUE){

  # Checks parameters
  if(!methods::is(snp.data, "GRanges") & !methods::is(snp.data, "List") & !methods::is(snp.data, "list")){
    stop("snp.data must be a GRanges or a list of GRanges")
  }



  if(!methods::is(snp.data, "GRanges") && (methods::is(snp.data, "List") || methods::is(snp.data, "list"))){
    if(all(unlist(lapply(snp.data, function(x) methods::is(x,"GRanges"))))){
      snp.data <- lapply(snp.data, function(x){
        removeNAs(snp.data = x, lrr.na = lrr.na, baf.na = baf.na, id.na = id.na, verbose = verbose)
      })
      return(snp.data)
    }else{
      stop("All elements of the list or GRangesList must be GRanges")

    }
  }


  if(!(is.logical(lrr.na) &&is.logical(baf.na) && is.logical(id.na) && is.logical(verbose))){
    stop("lrr.na, baf.na, id.na and verbose must be either TRUE or FALSE")
  }
  

  # We know snp.data is a GRanges and the other parameters are logical

  #Remove na from lrr
  if(lrr.na == TRUE){
    if("lrr" %in% names(GenomicRanges::mcols(snp.data))){
      na.values <- is.na(snp.data$lrr)
      snp.data <- snp.data[!(na.values)]
      if(verbose==TRUE) message("The number of NAs removed in LRR are : ", length(which(na.values)))

    }else{
      if(verbose==TRUE) message("lrr column not found in snp.data")
    }
  }

  #Remove na from baf
  if(baf.na == TRUE){
    if("baf" %in% names(GenomicRanges::mcols(snp.data))){
      na.values <- is.na(snp.data$baf)
      snp.data <- snp.data[!(na.values)]
      if(verbose==TRUE) message("The number of NAs removed in BAF are : ", length(which(na.values)))


    }else{
      if(verbose==TRUE) message("baf column not found in snp.data")
    }
  }

  #Remove na from id
  if(id.na == TRUE){
    if("id" %in% names(GenomicRanges::mcols(snp.data))){
      na.values <- is.na(snp.data$baf)
      snp.data <- snp.data[!(na.values)]
      if(verbose==TRUE) message("The number of NAs removed in ID are : ", length(which(na.values)))


    }else{
      if(verbose==TRUE) message("id column not found in snp.data")
    }
  }


  return(snp.data)
}


################### SeqLevelStyle ##############################################
#' UCSCStyle
#'
#' @description
#' Set the style of the chromosome names to UCSC ("chr1" instead of "1")
#'
#' @usage UCSCStyle(x)
#'
#' @param x (GRanges, GRangesList or list of GRanges) The object to transform to UCSC style
#'
#' @return
#' The same x object with the styles of the seqlevels set to UCSC
#'
#' @examples
#' #GRanges
#' seg.data <- regioneR::toGRanges(data.frame(chr = c("1", "1", "2", "5"), start = c(0,50000,8014630,14523572), end = c(48953, 7023664,9216331,153245687), lrr = c(NA,0.25,1.5,NA)))
#' seg.data <- UCSCStyle(seg.data)
#'
#' #List of GRanges
#' seg.data <- list(a = regioneR::toGRanges(data.frame(chr = c("1", "1", "2", "5"), start = c(0,50000,8014630,14523572), end = c(48953, 7023664,9216331,153245687), lrr = c(NA,0.25,1.5,NA),baf = c(1.5,2.5,NA,6), id = c("rs52456","rs52457","rs52458","rs52459"))),
#'                     b=regioneR::toGRanges(data.frame(chr = c("1", "1", "2", "5"), start = c(0,50000,8014630,14523572), end = c(48953, 7023664,9216331,153245687), lrr = c(2.5,NA,1.5,0.25), baf = c(1.5,2.5,NA,6), id = c("rs52456","rs52457","rs52458","rs52459"))))
#' seg.data <- UCSCStyle(seg.data)
#'
#' #GRangesList
#' seg.data <- GRangesList(a = regioneR::toGRanges(data.frame(chr = c("1", "1", "2", "5"), start = c(0,50000,8014630,14523572), end = c(48953, 7023664,9216331,153245687), lrr = c(NA,0.25,1.5,NA), baf = c(1.5,2.5,NA,6), id = c("rs52456","rs52457","rs52458","rs52459"))),
#'                         b = regioneR::toGRanges(data.frame(chr = c("1", "1", "2", "5"), start = c(0,50000,8014630,14523572), end = c(48953, 7023664,9216331,153245687), lrr = c(2.5,NA,1.5,0.25), baf = c(1.5,2.5,NA,6), id = c("rs52456","rs52457","rs52458","rs52459"))))
#' seg.data <- UCSCStyle(seg.data)
#'
#'
#' @export UCSCStyle
#' 
#' @importFrom GenomeInfoDb seqlevelsStyle
#'
UCSCStyle <- function(x) {
  if(methods::is(x, "list")) {
    if(all(unlist(lapply(x, methods::is, "GRanges")))) {
      for(i in seq_len(length(x))) {GenomeInfoDb::seqlevelsStyle(x[[i]]) <- "UCSC"}
      return(x)
    } else {
      stop("All elements of the list must be GRanges")
    }
  }
  if(methods::is(x, "GenomicRanges_OR_GenomicRangesList")) {
    GenomeInfoDb::seqlevelsStyle(x) <- "UCSC"
    return(x)
  }
  stop("Unknown class. Only GRanges, GRangesLists and lists of GRanges are accepted by UCSCStyle.")
}

#' EnsemblStyle
#'
#' @description
#' Set the style of the chromosome names to Ensembl ("chr1" instead of "1")
#'
#' @usage EnsemblStyle(x)
#'
#' @param x (GRanges, GRangesList or list of GRanges) The object to transform to Ensembl style
#'
#' @return
#' The same x object with the styles of the seqlevels set to Ensembl
#'
#' @examples
#' #GRanges
#' seg.data <- regioneR::toGRanges(data.frame(chr = c("chr1", "chr1", "chr2", "chr5"), start = c(0,50000,8014630,14523572), end = c(48953, 7023664,9216331,153245687), lrr = c(NA,0.25,1.5,NA)))
#' seg.data <- EnsemblStyle(seg.data)
#'
#' #List of GRanges
#' seg.data <- list(a = regioneR::toGRanges(data.frame(chr = c("chr1", "chr1", "chr2", "chr5"), start = c(0,50000,8014630,14523572), end = c(48953, 7023664,9216331,153245687), lrr = c(NA,0.25,1.5,NA),baf = c(1.5,2.5,NA,6), id = c("rs52456","rs52457","rs52458","rs52459"))),
#'                     b=regioneR::toGRanges(data.frame(chr = c("chr1", "chr1", "chr2", "chr5"), start = c(0,50000,8014630,14523572), end = c(48953, 7023664,9216331,153245687), lrr = c(2.5,NA,1.5,0.25), baf = c(1.5,2.5,NA,6), id = c("rs52456","rs52457","rs52458","rs52459"))))
#' seg.data <- EnsemblStyle(seg.data)
#'
#' #GRangesList
#' seg.data <- GRangesList(a = regioneR::toGRanges(data.frame(chr = c("chr1", "chr1", "chr2", "chr5"), start = c(0,50000,8014630,14523572), end = c(48953, 7023664,9216331,153245687), lrr = c(NA,0.25,1.5,NA), baf = c(1.5,2.5,NA,6), id = c("rs52456","rs52457","rs52458","rs52459"))),
#'                         b = regioneR::toGRanges(data.frame(chr = c("chr1", "chr1", "chr2", "chr5"), start = c(0,50000,8014630,14523572), end = c(48953, 7023664,9216331,153245687), lrr = c(2.5,NA,1.5,0.25), baf = c(1.5,2.5,NA,6), id = c("rs52456","rs52457","rs52458","rs52459"))))
#' seg.data <- EnsemblStyle(seg.data)
#'
#'
#' @export EnsemblStyle
#'
#'
EnsemblStyle <- function(x) {
  if(methods::is(x, "list")) {
    if(all(unlist(lapply(x, methods::is, "GRanges")))) {
      for(i in seq_len(length(x))) {GenomeInfoDb::seqlevelsStyle(x[[i]]) <- "Ensembl"}
      return(x)
    } else {
      stop("All elements of the list must be GRanges")
    }
  }
  if(methods::is(x, "GenomicRanges_OR_GenomicRangesList")) {
    GenomeInfoDb::seqlevelsStyle(x) <- "Ensembl"
    return(x)
  }
  stop("Unknown class. Only GRanges, GRangesLists and lists of GRanges are accepted by EnsemblStyle.")
}

################################# Prepare Labels to plot ###################################
#' prepareLabels
#'
#' @description
#' Prepare the Labels to plot. 
#'
#' @usage prepareLabels(labels, x)
#'
#' @param labels (character) labels to plot. (defaults to NULL)
#' @param x (list or GRangesList) The list or GRangesList where extracting the labels
#'
#' @return
#' prepareLabels return a vector with the same length as the length of x.
#' If labels is NULL and x have names, it will return the names of x.
#' If there are not names it will return numbers as labels.
#' If labes is not NULL, prepareLabels will cut or recycle the names as needed.
#
#' @examples
#' 
#' #List of GRanges
#' seg.data <- list(a = regioneR::toGRanges(data.frame(chr = c("chr1", "chr1", "chr2", "chr5"), start = c(0,50000,8014630,14523572), end = c(48953, 7023664,9216331,153245687), lrr = c(NA,0.25,1.5,NA),baf = c(1.5,2.5,NA,6), id = c("rs52456","rs52457","rs52458","rs52459"))),
#'                     b=regioneR::toGRanges(data.frame(chr = c("chr1", "chr1", "chr2", "chr5"), start = c(0,50000,8014630,14523572), end = c(48953, 7023664,9216331,153245687), lrr = c(2.5,NA,1.5,0.25), baf = c(1.5,2.5,NA,6), id = c("rs52456","rs52457","rs52458","rs52459"))))
#' prepareLabels(x = seg.data)
#'
#' #GRangesList
#' seg.data <- GRangesList(a = regioneR::toGRanges(data.frame(chr = c("chr1", "chr1", "chr2", "chr5"), start = c(0,50000,8014630,14523572), end = c(48953, 7023664,9216331,153245687), lrr = c(NA,0.25,1.5,NA), baf = c(1.5,2.5,NA,6), id = c("rs52456","rs52457","rs52458","rs52459"))),
#'                         b = regioneR::toGRanges(data.frame(chr = c("chr1", "chr1", "chr2", "chr5"), start = c(0,50000,8014630,14523572), end = c(48953, 7023664,9216331,153245687), lrr = c(2.5,NA,1.5,0.25), baf = c(1.5,2.5,NA,6), id = c("rs52456","rs52457","rs52458","rs52459"))))
#' 
#' prepareLabels(x = seg.data)
#' 
#' 
#' @export prepareLabels
#'
#'
prepareLabels <- function(labels = NULL, x){
  if(is.null(labels)){
    if(is.null(names(x))){
      labels <- seq_len(length(x))
    }else{
      labels <- names(x)
    }
  } else {
    if(length(labels)<length(x)){
      labels <- rep(labels, length.out=length(x))
    }
    if(length(labels)>length(x)){
      labels <- labels[seq_len(length(x))]
    }
  }
  return(labels)
}



##################### Single Cell and Ztrees ###################################

#' readHDF5Ztree
#'
#' @description
#' Read the Ztree (scipy matrix representarion of a hierarchical clustering)
#' contained in a 10X single-cell CNV HDF5 file and return a
#' valid R hclust object representing the same tree.
#' 
#' More info on the Ztree matrix: \url{https://joernhees.de/blog/2015/08/26/scipy-hierarchical-clustering-and-dendrogram-tutorial/}
#'
#' @usage readHDF5Ztree(hdf5.file)
#'
#' @param hdf5.file (H5IdComponent object) The result of opening an HDF5 file 
#' with rhdf5::H5Fopen(data.file). The file must contain a "tree" element 
#' with Ztree. For example, HDF5 files for CNV data produced by 10X CellRanger.
#'
#' @return
#' A valid hclust object (standard R hierarchical clustering results) 
#'
#' @examples
#' 
#' not.run <- TRUE #We have no valid hdf5 file small enough to fit in a package
#' #Not Run
#' #data.file <- "path to a single-cell CNV data file"
#' #open.file <- rhdf5::H5Fopen(data.file)
#' #hc.tree <- readHDF5Ztree(open.file)
#'
#' @export readHDF5Ztree

readHDF5Ztree <- function(hdf5.file) {
  if(!methods::is(hdf5.file, "H5IdComponent")) stop("hdf5.file must be a valid H5IdComponent. Use rhdf5::H5Fopen(data.file) to open the hdf5 file.")
  #Read the Ztree data
  Ztree <- rhdf5::h5read(hdf5.file, "tree/Z")
  num.cells <- ncol(Ztree)+1 #computed from tree structure
  
  reported.num.cells <- hdf5.file$constants$num_cells
  if(num.cells !=reported.num.cells) stop("The num cells computed from tree structure does not match the reported num cells")
  
  return(Ztree2Hclust(Ztree))
}



#' Ztree2Hclust
#'
#' @description
#' Transform a Z matrix representing the hierarchical clustering of elements
#' into a valid hclust R object. The Z representation is used by scipy 
#' hierarchical clustering and in 10X single-cell CNV HDF5 files.
#' 
#' More info on the Ztree matrix: \url{https://joernhees.de/blog/2015/08/26/scipy-hierarchical-clustering-and-dendrogram-tutorial/}
#'
#' @usage Ztree2Hclust(Ztree) 
#'
#' @param Ztree (matrix) A matrix with 4 rows and num.elements - 1 columns.
#' The first and second row represent the elements or clusters merged at each
#' step and the third row the distance between the merged elements. This
#' is the format used by scipy hierarchical clustering.
#'
#' @return
#' A valid hclust object (standard R hierarchical clustering results) 
#'
#' @examples
#' 
#' ztree <- matrix(c(0,4,0.1,2,
#'                   1,3,0.2,2,
#'                   5,2,0.3,2,
#'                   6,7,0.4,2),
#'                   nrow=4)
#'                 
#'  hc.tree <- Ztree2Hclust(ztree)
#'  plot(hc.tree)
#'
#' @export Ztree2Hclust


Ztree2Hclust <- function(Ztree) {
  #Tranform from the Ztree (used in python scipy and in 10X hdf5 files structure to
  #hclust used in R). They are similar but have different encodings for leaf objects.
  
  num.elements <- ncol(Ztree)+1
  #First prepare the z1 and z2 vectors, to build the merge matrix
  z1 <- Ztree[1,]
  z2 <- Ztree[2,]
  
  z1[z1<num.elements] <- -1*z1[z1<num.elements]-1 #in hclust, singletons are negative and indexing is 1-based
  z2[z2<num.elements] <- -1*z2[z2<num.elements]-1
  
  z1[z1>0] <- z1[z1>0] - num.elements + 1
  z2[z2>0] <- z2[z2>0] - num.elements + 1
  
  #And build the hclust object
  hctree <- list()
  class(hctree) <- "hclust"
  hctree$method <- "ZtreeImported"
  hctree$call <- NULL
  hctree$dist.method <- NULL
  
  #Set the merge matrix
  hctree$merge <- as.matrix(data.frame(z1, z2))
  #and the height vector
  hctree$height <- Ztree[3,]
  
  #Finally, recompute the plotting order
  hctree$order <- computeHclustPlotOrder(hctree$merge)
  
  return(hctree)
}


#' computeHclustPlotOrder
#'
#' @description
#' Given the merge matrix of an hclust object, compute a valid ordering of 
#' the samples so a dendogram can be plotted with no line crossings. 
#' 
#' Note: It's been implemented from scratch but in our experience reproduces
#' exactly the ordering produced by R own ordering algorithm used by hclust.
#' 
#' @usage computeHclustPlotOrder(m) 
#'
#' @param m (matrix) A merge matrix with 2 columns representing the merges
#' bewteen elements and clusters. The format is described in the documentation
#' of hclust.
#'
#' @return
#' A vector with the ordering of the nodes.
#'
#' @examples
#' 
#' ztree <- matrix(c(0,3,0.1,2,
#'                   1,4,0.2,2,
#'                   5,2,0.3,2,
#'                   6,7,0.4,2),
#'                   nrow=4)
#'                 
#'  hc.tree <- Ztree2Hclust(ztree)
#'  plot(hc.tree)
#'  
#'  #Set the ordering to a non-correct ordering
#'  hc.tree$order <- c(1:5)
#'  
#'  #When we plot, we see line crossings
#'  plot(hc.tree)
#'  
#'  #Compute a correct ordering and replot
#'  element.order <- computeHclustPlotOrder(hc.tree$merge)
#'  hc.tree$order <- element.order
#'  plot(hc.tree)
#'
#' @export computeHclustPlotOrder

computeHclustPlotOrder <- function(m) {
  n <- nrow(m)+1
  
  find.order <- function(step, o) {
    merged <- m[step,]
    for(i in c(1,2)) {
      if(merged[i]<0) {
        o$order[-merged[i]] <- o$last + 1
        o$last <- o$last + 1
      } else { #it's a cluster, call recursively find.order
        o <- find.order(merged[i], o)
      }
    }
    return(o)
  }
  
  o <- find.order(n-1, list(order=integer(n), last=0))
  return(order(o$order))
}




