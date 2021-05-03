# sraDownloader

## User manual and guide
sraDownloader uses [sratoolkit](https://github.com/ncbi/sra-tools) to download and convert sra files into fastq files and [trimmomatic](http://www.usadellab.org/cms/?page=trimmomatic) to separate the paired and unpaired reads. Trimmomatic won't trim the adapters in this pipeline. 

[Citation](#citation)   
[Download sraDownloader](#download-sradownloader)   
[Install sraDownloader Dependencies](#install-sradownloader-dependencies)   
[Using conda environments without sraDownloader](#using-conda-environments-without-sradownloader)   
[Running sraDownloader](#running-sradownloader)   
[Killing sraDownloader](#killing-sradownloader)   
[sraDownloader Example](#sradownloader-example)   
[Check log files](#check-log-files)   


## Citation
Savegnago, R. P. sraDownloader. 2021. GitHub repository, https://github.com/rodrigopsav/sraDownloader

<div align="right">
    <b><a href="#sradownloader">↥ back to top</a></b>
</div>

## Download sraDownloader

```
git clone https://github.com/rodrigopsav/sraDownloader.git 
```

<div align="right">
    <b><a href="#sradownloader">↥ back to top</a></b>
</div>

## Install sraDownloader Dependencies

sraDownloader dependencies are installed in a conda environment called sra. Before run sraDownloader, you **MUST** install the dependencies (sraDownloader/install_sra_dependencies/install_sra_dependencies.sh file) even if you have already installed the programs in your machine. To install sraDownloader dependencies, run:
```
cd sraDownloader/install_sra_dependencies
./install_sra_dependencies.sh -d <directory/to/install/sraDownloader/dependencies>
```

Unfortunately, incompatibilities can happen when install the most recent version of the programs. If you detect some errors after install sraDownloader dependencies, use the following command lines to remove the previous installation and re-install them with the versions used originally to develop sraDownloader:
```
conda env remove --name sra
./install_sra_dependencies_versions.sh -d <directory/to/install/sraDownloader/dependencies>
```

<div align="right">
    <b><a href="#sradownloader">↥ back to top</a></b>
</div>

## Using conda environments without sraDownloader

You can use all the programs without sraDownloader, by activating the proper conda environment:

```bash
conda activate sra
```
Try, fasterq-dump, prefetch and other programs installed in this conda env. To check a complete list of programs installed, type:

```
conda list
```

## Running sraDownloader

To run IVDP in a local machine, type:
```
./sraDownloader.sh -s 1 -l <sraList file> -n <number of parallel samples> -o <path/to/output/folder>
```
and to run on a HPCC with slurm scheduler, type:
```
./sraDownloader.sh -s 2 -l <sraList file> -n <number of parallel samples> -o <path/to/output/folder>
```
       -s: submission system (1: local server; 2: HPCC with slurm)
       -l: path to list of sra run accessions
       -n: number of samples to run in parallel (default=5: DO NO WORK WITH HPCC)
       -o: output directory

<div align="right">
    <b><a href="#sradownloader">↥ back to top</a></b>
</div>

## Killing sraDownloader

In the end of each submission, sraDownloader shows a message to kill the analysis like that:

```
# sraDownloader running in a local server
To kill this SRA analysis, run: kill -- 1463

# sraDownloader running on HPCC with slurm
for job in $(squeue -u $USER | grep 463739 | awk '{print \$1}'); do scancel $job; done

```

**NOTE**: each analysis shows a different number (like 1463 and 463739 in the example above. Copy and paste these command lines anywhere until the analysis finishes (just in case you want to stop it earlier).

<div align="right">
    <b><a href="#sradownloader">↥ back to top</a></b>
</div>

## sraDownloader Example

On a local machine, type:
```
./sraDownloader.sh -s 1 -l sraList/exampleSRA.txt -n 10 -o ~/outSRA
```
and to run on a HPCC with slurm scheduler, type:
```
./sraDownloader.sh -s 2 -l sraList/exampleSRA.txt -o ~/outSRA
```

<div align="right">
    <b><a href="#sradownloader">↥ back to top</a></b>
</div>


## Check log files

When sraDownloader finishes the jobs, go to the output folder, subfolder samples:

```
cd ~/outSRA/samples
```

There are three files:
* sra_list.txt   
* sra_download_convert_successful.txt   
* sra_download_convert_failed.txt

Check failed samples in sra_download_convert_failed.txt. Pretend that sample ERR1742684 failed. To get more details about it, go to:
```
cat ~/outSRA/log/ERR1742684.txt | less
```

<div align="right">
    <b><a href="#sradownloader">↥ back to top</a></b>
</div>
