import os

def yes_no():
    "Return true/false to a question"
    return input("> ").lower() == "y"

os.chdir("./Data_Cleaning") #change the directory 'coz everything is there

print("Do You want to execute everything?[Y,n]")
if yes_no():
    import get_data
    os.system("./PigCleaning.sh")
    os.system("./neo4j_import.sh")
else:
    print("Do you want to pre-process the raw data? [Y,n]")
    if yes_no():
        import get_data

    print("Do you want to process the data with PIG [Y,n]")
    if yes_no():
        os.system("./PigCleaning.sh")

    print("Do you want to create a graph database [Y,n]")
    if yes_no():
        os.system("./neo4j_import.sh")
