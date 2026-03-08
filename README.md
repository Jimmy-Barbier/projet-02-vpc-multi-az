# 🏗️ Projet 02 — VPC Multi-AZ · Flask · RDS MySQL

> 🚧 **EN CONSTRUCTION** — Projet en cours de réalisation

---

## 📌 Objectif

Concevoir et déployer une infrastructure AWS production-ready en suivant les bonnes pratiques du **AWS Well-Architected Framework**.

Une application web Python (Flask) de gestion de contacts est hébergée sur des instances EC2 dans des **subnets publics**, et communique avec une base de données **RDS MySQL** isolée dans des **subnets privés** — le tout réparti sur **2 Availability Zones** pour la haute disponibilité.

---

## 🏛️ Architecture

```
Internet
    │
    ▼
┌─────────────────────────────────┐
│     Application Load Balancer   │
└─────────────────────────────────┘
    │
    ▼
┌───────────────┐   ┌───────────────┐
│ Subnet Public │   │ Subnet Public │
│    AZ-a       │   │    AZ-b       │
│  EC2 (Flask)  │   │  EC2 (Flask)  │
└───────────────┘   └───────────────┘
    │
    ▼
┌───────────────┐   ┌───────────────┐
│ Subnet Privé  │   │ Subnet Privé  │
│    AZ-a       │   │    AZ-b       │
│  RDS MySQL    │   │  RDS MySQL    │
│  (Primary)    │   │  (Standby)    │
└───────────────┘   └───────────────┘
```

---

## ⚙️ Stack technique

| Composant | Service AWS | Détail |
|---|---|---|
| Application | EC2 t2.micro | Python Flask |
| Base de données | RDS MySQL t3.micro | Subnets privés |
| Load Balancer | Application Load Balancer | Multi-AZ |
| Scaling | Auto Scaling Group | Min 1 / Max 2 |
| Réseau | VPC custom | 2 AZ · pub/priv |
| Sortie internet (privé) | NAT Gateway | Subnet public AZ-a |
| Sécurité | Security Groups + NACL | Principe moindre privilège |

---

## 🗂️ Structure du repo

```
projet-02-vpc-multi-az/
├── README.md
├── app/
│   ├── app.py
│   ├── requirements.txt
│   └── templates/
│       └── index.html
└── assets/
    ├── architecture-diagram.png
    └── captures/
```

---

## 🚀 Étapes de réalisation

- [ ] Création du VPC et des subnets (pub/priv · 2 AZ)
- [ ] Internet Gateway + NAT Gateway
- [ ] Route Tables (publique et privée)
- [ ] Security Groups + NACL
- [ ] Déploiement RDS MySQL (subnet privé)
- [ ] Déploiement EC2 + installation Flask
- [ ] Configuration Application Load Balancer
- [ ] Auto Scaling Group
- [ ] Tests de connectivité et validation

---

## 🛠️ Technologies

![AWS](https://img.shields.io/badge/AWS-232F3E?style=flat&logo=amazonaws&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-000000?style=flat&logo=flask&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=flat&logo=mysql&logoColor=white)

---

## 👤 Auteur

**Jimmy Barbier** — Cloud Engineer AWS en reconversion  
🌐 [Portfolio](https://jimmy-barbier.github.io/portfolio/) · 💼 [LinkedIn](https://www.linkedin.com/in/jimmy-barbier-89740539a/)
