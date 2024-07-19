
cd /path/to/wdir
dir=data/cnvkit/results
mkdir -p $dir
module load R/4.1.0
module load anaconda3/2021.05
source activate /path/to/.conda/envs/cnvkit


# Link or copy bam files to the bams folder
mkdir data/bams



refgen=/path/to/reference_genomes/bwa06_1KGRef_PhiX/hs37d5_PhiX.fa
annos=/path/to/gene_annotations/Homo_sapiens.GRCh37.87.gff3



# run everything in batch
# bsub -R "rusage[mem=100G]" -q "verylong" -n 64 -J "cnvkit_wgs" cnvkit.py batch --method wgs data/bams/*organoids.bam --normal data/bams/*germline.bam \
#     --fasta $refgen --annotate $annos --diagram --scatter \
#     --output-reference data/cnvkit/my_reference.cnn --output-dir $dir
    


# Or for each sample in parallel...
for PID in PDO-45 PDO-35 PDO-789; do
  echo $PID
  bsub -R "rusage[mem=50G]" -q "long" -n 50 cnvkit.py coverage data/bams/${PID}_organoids.bam $dir/hs37d5_PhiX.target.bed -o $dir/${PID}_organoids.targetcoverage.cnn
  bsub -R "rusage[mem=1G]" -q "long" -n 10 cnvkit.py coverage data/bams/${PID}_organoids.bam $dir/hs37d5_PhiX.antitarget.bed -o $dir/${PID}_organoids.antitargetcoverage.cnn
  bsub -R "rusage[mem=50G]" -q "long" -n 50 cnvkit.py coverage data/bams/${PID}_germline.bam $dir/hs37d5_PhiX.target.bed -o $dir/${PID}_germline.targetcoverage.cnn
  bsub -R "rusage[mem=1G]" -q "long" -n 10 cnvkit.py coverage data/bams/${PID}_germline.bam $dir/hs37d5_PhiX.antitarget.bed -o $dir/${PID}_germline.antitargetcoverage.cnn
  bsub -R "rusage[mem=50G]" -q "long" -n 50 cnvkit.py coverage data/bams/${PID}_tumour.bam $dir/hs37d5_PhiX.target.bed -o $dir/${PID}_tumour.targetcoverage.cnn
  bsub -R "rusage[mem=1G]" -q "long" -n 10 cnvkit.py coverage data/bams/${PID}_tumour.bam $dir/hs37d5_PhiX.antitarget.bed -o $dir/${PID}_tumour.antitargetcoverage.cnn
done


for PID in PDO-45 PDO-35 PDO-789; do
  echo $PID
  bsub -R "rusage[mem=20G]" -q "long" -n 20 cnvkit.py fix $dir/${PID}_organoids.targetcoverage.cnn $dir/${PID}_organoids.antitargetcoverage.cnn data/cnvkit/my_reference.cnn -o $dir/${PID}_organoids.cnr
  bsub -R "rusage[mem=20G]" -q "long" -n 20 cnvkit.py fix $dir/${PID}_germline.targetcoverage.cnn $dir/${PID}_germline.antitargetcoverage.cnn data/cnvkit/my_reference.cnn -o $dir/${PID}_germline.cnr
  bsub -R "rusage[mem=20G]" -q "long" -n 20 cnvkit.py fix $dir/${PID}_tumour.targetcoverage.cnn $dir/${PID}_tumour.antitargetcoverage.cnn data/cnvkit/my_reference.cnn -o $dir/${PID}_tumour.cnr
done
  
#then after all jobs finished
for PID in PDO-45 PDO-35 PDO-789; do
  echo $PID
  bsub -R "rusage[mem=20G]" -q "long" -n 20 cnvkit.py segment $dir/${PID}_organoids.cnr -o $dir/${PID}_organoids.cns
  bsub -R "rusage[mem=20G]" -q "long" -n 20 cnvkit.py segment $dir/${PID}_germline.cnr -o $dir/${PID}_germline.cns
  bsub -R "rusage[mem=20G]" -q "long" -n 20 cnvkit.py segment $dir/${PID}_tumour.cnr -o $dir/${PID}_tumour.cns
done




#link tumour and normal into separate folders for heatmap plotting
for PID in PDO-45 PDO-35 PDO-789; do
  cp $dir/$PID*.cn{s,r} $dir/tumour_organoids/
done


# subset chromosomes in cns and cnr files, to only include canonical autosomes and sex chromosomes
mkdir $dir/normal_organoids/chr_subset/
for file in $dir/normal_organoids/*.cn{s,r}; do
  nam=${file##*/}
  bsub -R "rusage[mem=1G]" -q "medium" "grep -E '^(chromosome|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|X)\b' $file > $dir/normal_organoids/chr_subset/$nam"
done
mkdir $dir/tumour_organoids/chr_subset/
for file in $dir/tumour_organoids/*.cn{s,r}; do
  nam=${file##*/}
  bsub -R "rusage[mem=1G]" -q "medium" "grep -E '^(chromosome|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|X)\b' $file > $dir/tumour_organoids/chr_subset/$nam"
done

#heatmaps
bsub -R "rusage[mem=10G]" -q "long" -n 20 -J "cnvkit_hm" cnvkit.py heatmap $dir/*.cns -d -o $dir/../plots/heatmap_allsamples_denoised.pdf
bsub -R "rusage[mem=10G]" -q "long" -n 20 -J "cnvkit_hm" cnvkit.py heatmap $dir/normal_organoids/chr_subset/*.cns -d -o $dir/../plots/heatmap_normals_denoised.pdf
bsub -R "rusage[mem=10G]" -q "long" -n 20 -J "cnvkit_hm" cnvkit.py heatmap $dir/tumour_organoids/chr_subset/*.cns -d -o $dir/../plots/heatmap_tumourous_denoised.pdf
bsub -R "rusage[mem=10G]" -q "long" -n 20 -J "cnvkit_hm" cnvkit.py heatmap $dir/normal_organoids/chr_subset/*.cns -o $dir/../plots/heatmap_normals.pdf
bsub -R "rusage[mem=10G]" -q "long" -n 20 -J "cnvkit_hm" cnvkit.py heatmap $dir/tumour_organoids/chr_subset/*.cns -o $dir/../plots/heatmap_tumourous.pdf

#scatter diagrams:
for i in $dir/{tumour,normal}_organoids/chr_subset/*.cnr; do 
  pid=${i##*/}
  pid=${pid%.cnr}
  echo $i
  echo $pid
  bsub -R "rusage[mem=5G]" -q "medium" -J "cnvkit_scatters" cnvkit.py scatter -s ${i%.cnr}.cn{s,r} -o $dir/../plots/scatter/${pid}_genome_scatter.png
done
# without segmentation calls
for i in $dir/{tumour,normal}_organoids/chr_subset/*.cnr; do 
  pid=${i##*/}
  pid=${pid%.cnr}
  echo $i
  echo $pid
  bsub -R "rusage[mem=5G]" -q "medium" -J "cnvkit_scatters" cnvkit.py scatter $i -o $dir/../plots/scatter/no_segments/${pid}_genome_scatter_noseg.png
done
