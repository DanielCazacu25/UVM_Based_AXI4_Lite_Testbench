import subprocess
import random
import os
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--number', type = int, default = 10)
parser.add_argument("--folder", type = str, default = r'C:\Users\Daniel\OneDrive\Desktop\Pentru Verilog\Module verilog\project_2\project_2.sim\sim_1\behav\xsim')
parser.add_argument("--settings", type = str, default = r'D:\Vivado\2025.2\Vivado\settings64.bat')
args = parser.parse_args()
if(args.number < 1) :
    parser.error("Invalid number | The number of simulation can't be less that one")
if(os.path.isdir(args.folder) == False) :
    parser.error("Invalid folder path")
if(os.path.basename(args.settings) != "settings64.bat") :
    parser.error("Wrong file selected")
if(os.path.isfile(args.settings) == False) :
    parser.error("Wrong path to settings64 file")
numb_tests = args.number
folder = args.folder
pass_count = 0
fail_count = 0
folder_script = os.path.dirname(os.path.abspath(__file__))
principal_folder = os.path.dirname(folder_script)
folder_path = os.path.join(principal_folder, "logs")
os.makedirs(folder_path,exist_ok=True)
general_logs = os.path.join(folder_path, "summary.txt")
errors_logs = os.path.join(folder_path, "errors.txt")
tests = ["UVM_TESTNAME=AXI4Lite_test","UVM_TESTNAME=AXI4Lite_ral_test"]
seed = random.sample(range(1,2**31),numb_tests)
with open(general_logs, "w") as gen_log:
    with open(errors_logs, "w") as err_log:
        for current_sim, current_seed in zip(range(1 , numb_tests + 1), seed):
            for current_test in tests :
                command = fr'call "{args.settings}" && xsim AXI4Lite_top_behav -R -testplusarg "{current_test}" -sv_seed {current_seed}'
                result = subprocess.run(
                            args = command,
                            shell=True,
                            cwd = folder,
                            capture_output=True,
                            text = True
                        )
                text = result.stdout.splitlines()
                sim_finished = 0
                problems_list = []
                warnings = 0
                errors = 0
                fatal = 0
                for i in text :
                    if(i.startswith("UVM_WARNING :")) :
                        i_split = i.split(":")
                        warnings = int(i_split[1])
                    if(i.startswith("UVM_WARNING ") == True and i.startswith("UVM_WARNING :") == False) :
                        problems_list.append(i)
                    if(i.startswith("UVM_ERROR :")) :
                        i_split = i.split(":")
                        errors = int(i_split[1])
                    if(i.startswith("UVM_ERROR ") == True and i.startswith("UVM_ERROR :") == False) :
                        problems_list.append(i)
                    if(i.startswith("UVM_FATAL :")) :
                        i_split = i.split(":")
                        fatal = int(i_split[1])
                        sim_finished = 1
                    if(i.startswith("UVM_FATAL ") == True and i.startswith("UVM_FATAL :") == False) :
                        problems_list.append(i)

                if(sim_finished == 0) :
                    gen_log.write(f"Test : {current_test} |Seed : {current_seed} |Simulation : {current_sim} : Failed to end the simulation\n")
                    err_log.write(f"===Test : {current_test} |Seed : {current_seed} |Simulation : {current_sim}===\n")
                    err_log.write(f"{result.stderr}\nError code : {result.returncode}\n")
                    for i in problems_list :
                        err_log.write(f"{i}\n")
                    fail_count = fail_count + 1
                else:
                    ok = 1
                    if(warnings != 0) :
                        ok = 0
                    if(errors != 0) :
                        ok = 0
                    if(fatal != 0) :
                        ok = 0
                    if(ok == 1) :
                        gen_log.write(f"Test : {current_test} |Seed : {current_seed} |Simulation : {current_sim} : PASS\n")
                        pass_count = pass_count + 1
                    if(ok == 0) :
                        gen_log.write(f"Test : {current_test} |Seed : {current_seed} |Simulation : {current_sim} : FAIL\n")
                        err_log.write(f"===Test : {current_test} |Seed : {current_seed} |Simulation : {current_sim}===\n")
                        for i in problems_list :
                            err_log.write(f"{i}\n")
                        fail_count = fail_count + 1
print(f"Summary: {numb_tests * len(tests)} tests were executed | {pass_count} tests passed | {fail_count} tests failed")