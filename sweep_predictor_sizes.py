

#first paramterize the runGem5.sh script
#read the correct fields in the correct file,
#calculate CPI

import subprocess 
import os
import re


def calculate_CPI(benchmark, L1D_SIZE="128kB", L1I_SIZE="128kB", L2_SIZE="1MB", L1D_ASSOC="2", L1I_ASSOC="2", L2_ASSOC="4", CACHE_LINE="64",MAX_INST="500000000", CPU_TYPE="DerivO3CPU"):

    base_dir = os.path.dirname(os.path.abspath(__file__))
    script_path = os.path.join(base_dir, "runGem5_param.sh")
    subprocess.run([script_path, benchmark, L1D_SIZE, L1I_SIZE, L2_SIZE, L1D_ASSOC, L1I_ASSOC, L2_ASSOC, CACHE_LINE, MAX_INST, CPU_TYPE ])
    stats = { '401.bzip2' : "401.bzip2/m5out/stats.txt",
              '429.mcf': "429.mcf/m5out/stats.txt",
              '456.hmmer': "456.hmmer/m5out/stats.txt",
              '458.sjeng': "458.sjeng/m5out/stats.txt" ,
              '470.lbm': "470.lbm/m5out/stats.txt" , 
    }
    file = open(stats[benchmark], "r")
    lines = file.readlines()
    numInsts = 1
    dcacheMisses = 0
    icacheMisses = 0
    l2Misses = 0
    BTBMissPct = 0
    BranchMispredPercent = 0
    for line in lines:
        pattern = r'(?<!\S)\d+(?!\S)'
        if "system.cpu.commitStats0.numInsts " in line:
            numInsts = re.findall(pattern, line)[0]
        if "system.cpu.dcache.overallMisses::total" in line:
            print("found dcahce misses")
            dcacheMisses = re.findall(pattern, line)[0]
        if "system.cpu.icache.overallMisses::total" in line:
            icacheMisses = re.findall(pattern, line)[0]
        if "system.l2.overallMisses::total" in line:
            l2Misses = re.findall(pattern, line)[0]
        if "system.cpu.branchPred.BranchMispredPercent" in line:
            BranchMispredPercent =  float(line.split()[1])
        if "system.cpu.branchPred.BTBMissPct " in line:
            BTBMissPct = float(line.split()[1])
    print("dcacheMisses", dcacheMisses)
    print("icacheMisses", icacheMisses)
    print("l2Misses", l2Misses)
    print("numInsts", numInsts)
    print(((int(dcacheMisses) + int(icacheMisses))*10 + int(l2Misses)*80)/int(numInsts))
    CPI = 1+((int(dcacheMisses) + int(icacheMisses))*10 + int(l2Misses)*80)/int(numInsts)
        
    return CPI, BTBMissPct, BranchMispredPercent



line_numbers = {
    "localPredictorSize":192,
    "globalPredictorSize":193,
    "localHistoryTableSize":194
}

def run_benchmarks(attribute, size,output_file):
    filename = "/home/casp26p1/gem5/src/cpu/o3/BaseO3CPU.py"
    print("modifying BaseO3CPU.py")
    with open(filename, "r") as f:
        lines = f.readlines()
  
    for i, line in enumerate(lines):
        if attribute in line:
            lines[i] = f"        {attribute}={size},\n"
            break

    # Write the modified contents back
    with open(filename, "w") as f:
        f.writelines(lines)

    print("Recompiling")
    gem5_dir = "/home/casp26p1/gem5/"

    subprocess.run(
    ["scons", "build/X86/gem5.opt"],
    cwd=gem5_dir,
    input=b"y\n",
    check=True
)
    print("running benchmarks")   
    benchmarks = ["401.bzip2", "429.mcf", "456.hmmer", "458.sjeng", "470.lbm"] 
    sweep_results = []
    for benchmark in benchmarks:
        result = [size,benchmark]
        cpi, btbMissPct, branchMisPredPct = calculate_CPI(benchmark)
        print("cpi", cpi, "btbMissPct", btbMissPct, "branchMisPredPct",branchMisPredPct)
        result.append(cpi)
        result.append(btbMissPct)
        result.append(branchMisPredPct)
        sweep_results.append(result)
        
    print(f"size {size} results for attribute {attribute}")
    print(sweep_results)

    import os 

    with open(output_file, "a") as file:
        for row in sweep_results:
            file.write(",".join(map(str, row)) + "\n")



#sweeping for local predictor size
sizes = [128, 256, 512, 1024, 2048, 4096]
sizes = [128]
for size in sizes:
    run_benchmarks( "localPredictorSize", size, "localPredictroSize_sweep.txt")
    
"""    
sizes = [1024, 2048, 4096, 8192, 16384]
for size in sizes:
    run_benchmarks( "globalPredictorSize", size, "globalPredictroSize_sweep.txt")
    
    
    
sizes = [64, 128, 256, 512, 1024]
for size in sizes:
    run_benchmarks("localHistoryTableSize", size,  "localHistoryTableSize_sweep.txt")
"""   

        
