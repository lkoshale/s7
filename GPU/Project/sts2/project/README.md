# sts2

This is the project for sparse tensor transpose project for gpu programming.
Instructions
Add your names to the README.md and commit the repo with the title "added autho

## Generate data
   -  it takes input first line as rank extents (separetd by space) then a number which denotes % sparsity.

   - > python3 GenData.py > outputfile
	4 16 15 23 18
	50

   - above generates data file (outputfile) with rank 4 and extents 16 15 23 18 and 50% sparsity


# How to Run code
  - Compile using nvcc ex: nvcc sparse.cu -o a.out
  - Run:  ./a.out < datafile > outfile

  - first line of outfile contains run time and next line contains transposed tensor

## Names
    - Lokesh Koshale (CS15B049)
    - Ch.S.Akshay Kumar (CS15B011)
