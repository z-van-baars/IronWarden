# Pythono3 code to rename multiple 
# files in a directory or folder
  
# importing os module
import os
  
# Function to rename multiple files
def main():
    subdirs_to_rename = []
    pathdir = os.getcwd()
    print(pathdir)
    for dir_item in os.listdir():
        if os.path.isdir(pathdir + "/" + dir_item):
            subdirs_to_rename.append(pathdir+"/"+dir_item)
    for subdir in subdirs_to_rename:
        print(subdir)
        for count, filename in enumerate(os.listdir(subdir)):
            if filename[:2] == "00": continue
            if len(filename) == 5:
                dst = "/000" + filename
            elif len(filename) == 12 and filename[5:] == ".import":
                dst = "/000" + filename
            else:
                dst = "/00" + filename
            src = subdir + "/" + filename
            dst = subdir + dst
              
            # rename() function will
            # rename all the files
            os.rename(src, dst)
  
# Driver Code
if __name__ == '__main__':
      
    # Calling main() function
    main()
