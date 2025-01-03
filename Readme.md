🛫 TFG Wing Modeling Project
📚 Overview
This project focuses on developing a streamlined workflow for wing structural modeling, aligned with the guidelines from tfg_guia_Modelo FEM de la estructura de un ala and Etapa-3-predimensionado-cajon-ala-metalico-compuesto. The workflow bridges structural parameters to Key Geometry Entities (points, lines, surfaces) for efficient structural analysis.

Workflow Overview:
MATLAB → FreeCAD (Python script, .csv → .step) → Siemens Solid Edge (.step → Parasolid) → Patran

🛠️ Structure and Key Components
Data Storage: TFG_amora.mat – Master data file with all structural parameters.
Main Compiler Script: TFG_wing_struct.m – Central script managing wing and fuselage construction.
Wing Construction Scripts: construirAla_vX.m – Generates ribs, stringers, points, lines, and surfaces.
Fuselage Construction Scripts: construir_fuselaje_vX.m – Similar to wing construction.
In Progress: generar_estructura_all.m – Creating bars and surfaces for ribs and spars.
🎯 Goals
Complete the streamlined workflow.
Develop multiple simulation case studies for various structural parameters.
Present a structural analysis thesis rich with data for academic and industrial application.
📊 Expected Outcomes
Efficiently generated geometry entities for FEM simulations.
Comprehensive structural analysis datasets.
A thesis demonstrating an automated, scalable modeling workflow.
🤝 Collaboration Workflow
All MATLAB scripts and outputs are organized into /Code and /Data.
Regular commits and updates will be tracked via GitHub.
Discussions and tasks will be managed using GitHub Issues.
📂 Folder Structure
bash
Copy code
/Project_Root
│
├── Code/             # MATLAB scripts for construction and analysis
│   ├── TFG_main.m
│   ├── TFG_wing_struct.m
│   ├── construirAla_vX.m
│   ├── construir_fuselaje_vX.m
│   ├── generar_estructura_all.m
│
├── Data/             # Master structural data file
│   ├── TFG_amora.mat
│
├── Docs/             # Project documentation and guidelines
│
├── Results/          # Simulation results, figures, logs
│
└── Notes/            # Progress notes and additional documentation
📅 Next Steps
Finalize generar_estructura_all.m for bar creation.
Develop surface generation for ribs and spars.
Prepare datasets for Patran and complete simulations.
✍️ Author
Jess Amora – Aerospace Engineering Student at ETSIAE, UPM.
📬 Feedback & Contributions
For suggestions, please create an Issue on this repository or reach out directly.

