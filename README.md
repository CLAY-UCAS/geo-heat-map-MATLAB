# geo-heat-map-MATLAB
README.md
========
EXIOBASE-Hidden-Metal-World-Heatmap  
A MATLAB pipeline to compute and visualize the global distribution of **hidden metal flows** derived from EXIOBASE v3 multi-regional input–output data.
1. Project Overview
- Background  
  EXIOBASE provides complete supply-chain data.  
  This project focuses on the **difference between metal extraction embodied in consumption (CBA) and direct production (PBA)**—i.e., the “hidden” metal footprint.

- Goal  
  Interactively select industries and metals, then generate a high-resolution world heatmap that instantly shows each country’s hidden metal balance.
2. Repository Structure
├─ README.md               # This file
├─ data/
│   ├─ data_D_cba.mat
│   ├─ data_D_pba.mat
│   ├─ data_U_cba.mat
│   └─ data_U_pba.mat      # Raw EXIOBASE .mat files
├─ shapefile/
│   └─ ne_110m_admin_0_countries.shp
3. Requirements
| Dependency | Version |
|---|---|
| MATLAB | R2019a or newer |
| Mapping Toolbox | Required |
| Statistics & Machine Learning Toolbox | For `accumarray` |
| Shapefile | Natural Earth 1:110 m Admin 0 Countries |

The script automatically downloads and unzips the shapefile the first time it is run.
4. Quick Start
1. Clone the repo  
   ```bash
   git clone https://github.com/CLAY-UCAS/geo-heat-map-MATLAB.md
2. Launch MATLAB, set the current folder to the repo root, and run  
   ```matlab
   main
   ```
3. Follow the interactive prompts  
   - Choose industries (multiple IDs allowed, space-separated)  
   - Pick the metal column to visualize  
   - Decide whether to clip outliers (none / max / min / both)  
   - Enter color-level N (default 256)

4. When finished, the figure pops up and is saved as  
   `results/heatmap.png`

