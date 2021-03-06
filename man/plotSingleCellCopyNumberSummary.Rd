% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotSingleCellCopyNumberSummary.R
\name{plotSingleCellCopyNumberSummary}
\alias{plotSingleCellCopyNumberSummary}
\title{plotSingleCellCopyNumberSummary}
\usage{
plotSingleCellCopyNumberSummary(karyoplot, cnv.file, direction="in",  gain.color=NULL, normal.color=NULL, loss.color=NULL, r0=0, r1=1, ...)
}
\arguments{
\item{karyoplot}{A karyoplot object}

\item{cnv.file}{(an HDF5 file) The path to an HDF5 file containing the single-cell CNV data.}

\item{direction}{The direction to which the coverage plot point, either "in" for inward or "out" for outward. (defaults to "in")}

\item{gain.color}{(color) The color assigned to gains (defaults to NULL)}

\item{normal.color}{(color) The color assigned to normal ploidy(defaults to NULL)}

\item{loss.color}{(colors) The color assigned to losses(defaults to NULL)}

\item{r0}{(numeric) (karyoploteR parameter) r0 and r1 define the vertical range of the data panel to be used to draw this plot. They can be used to split the data panel in different vertical ranges (similar to tracks in a genome browser) to plot differents data. If NULL, they are set to the min and max of the data panel, it is, to use all the available space. (defaults to NULL)(defaults to 0)}

\item{r1}{(numeric) (karyoploteR parameter) r0 and r1 define the vertical range of the data panel to be used to draw this plot. They can be used to split the data panel in different vertical ranges (similar to tracks in a genome browser) to plot differents data. If NULL, they are set to the min and max of the data panel, it is, to use all the available space. (defaults to NULL)(defaults to 1)}

\item{...}{The ellipsis operator can be used to specify any additional graphical parameters. Any additional parameter will be passed to the internal calls to karyoploteR functions.}
}
\value{
Invisibly returns the karyoplot object representing the plot. With it
it is possible to add other elements to the plot using standrad karyoploteR
functions. The returned object will have an additional "latest.plot" 
element with a list containing: the number of cells, the bin size used to 
partition the genome, the windows representing such partitioning with
the number of cells with gains and losses in that each window,
the number of bins per chromosome and a GRanges with the regions where 
no cell had any data, the no-call regions.
}
\description{
Plot a summary of the copy number calls from a single-cell CNV data file. 
Plot a histogram-like plot with the number of cells with gains and losses. 
The file must be an HDF5 file with the same format as the
ones produced by 10X CellRanger software.
}
\details{
This function will open the HDF5 file, extract the CNV values and counts,
for each genomic region, the number of cells with a gain or a loss. It 
then plots a histogram-like summary of these numbers.
}
\note{
If the file is open by any other application the function will fail.
}
\examples{

kp <- plotKaryotype(plot.type=4, genome="hg38")
#NOT RUN - Using 10X example data from https://www.10xgenomics.com/resources/datasets/
#plotSingleCellCopyNumberSummary(kp, "breast_tissue_D_2k_cnv_data.h5")


}
