rule targets:
    input:
        "data/ghcnd_all.tar.gz",
        "data/ghcnd_all_files.txt",
        "data/ghcnd-inventory.txt",
        "data/ghcnd-stations.txt",
        "data/ghcnd_tidy.tsv.gz",
        "data/ghcnd_regions.tsv"


rule get_all_archive:
    input:
        script = "code/get_ghcnd_data.bash"
    output:
        "data/ghcnd_all.tar.gz"
    params:
        file = "ghcnd_all.tar.gz"
    shell:
        """
        {input.script} {params.file}
        """

   
rule get_all_filenames:
    input:
        script = "code/get_ghcnd_all_files.bash",
        archive = "data/ghcnd_all.tar.gz"
    output:
        "data/ghcnd_all_files.txt"
    shell:
        "{input.script}"

rule get_inventory:
    input:
        script = "code/get_ghcnd_data.bash"
    output:
        "data/ghcnd-inventory.txt"
    params:
        file = "ghcnd-inventory.txt"
    shell:
        """
        {input.script} {params.file}
        """

rule get_station_data:
    input:
        script = "code/get_ghcnd_data.bash"
    output:
        "data/ghcnd-stations.txt"
    params: 
        file = "ghcnd-stations.txt"
    shell:
        """
        {input.script} {params.file}
        """


rule summarize_dly_files:
    input:
        bash_script = "code/concatenate_dly.bash",
        r_script = "code/read_split_dly_files.R",
        tarball = "data/ghcnd_all.tar.gz"
    output: 
        "data/ghcnd_tidy.tsv.gz"
    shell:
        """
        {input.bash_script}
        """
 
rule aggregate_stations:
    input:
        r_script = "code/merge_lat_long.R",
        data = "data/ghcnd-stations.txt"
    output:
        "data/ghcnd_regions.tsv"
    shell:
        """
        {input.r_script}
        """
