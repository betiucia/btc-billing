# btc-billing

**btc-billing** is a simple, direct, and highly efficient billing script developed as a core part of the BTC ecosystem. This is a **btc script** specifically built to work seamlessly with **btc-business**, providing a robust "pay-later" billing solution for your server's businesses.

## 🌟 Overview

Designed to empower roleplay businesses, `btc-billing` allows employees to issue bills to customers. The customer receives an offer prompt that they can either accept or decline. Once accepted, the debt is recorded, and the customer can pay it at their convenience. 

When a bill is paid, the funds are automatically deposited into the corresponding business safe via **btc-business**, ensuring smooth financial operations for player-owned enterprises.

## ✨ Features

- **Business Integration:** Native integration with **btc-business**. Paid bills are directly deposited into the business account.
- **Interactive Offers:** Customers get an on-screen prompt to accept or decline a bill before the debt is created.
- **Job Management:** Employees can check active bills issued by their job.
- **Player Management:** Players can check and pay their outstanding debts at any time.
- **Admin/Special Job Access:** Configurable jobs (like Police/Sheriff) or Admins can view all server bills.
- **Discord Webhooks:** Built-in webhook logging for created and paid bills.
- **Highly Configurable:** Set min/max bill amounts, offer timeouts, allowed jobs, and more via `config.lua`.

## 📦 Dependencies

- **btc-core**
- **btc-business**
- **oxmysql**

## 💻 Commands

By default, the following commands are available (can be changed in the config):

- `/createbill` - Opens the prompt to issue a new bill to a nearby player (Restricted to configured jobs).
- `/bills` - Lists all active bills issued by your job.
- `/mybills` - Lists your personal active bills and allows you to pay them.

## ⚙️ How it Works

1. **Issue a Bill:** An employee uses `/createbill` to send a billing offer to a player.
2. **Acceptance:** The targeted player has a set amount of time (e.g., 60 seconds) to accept the bill.
3. **Recording:** Once accepted, the bill is saved in the database as an active debt.
4. **Payment:** The debtor uses `/mybills` to pay the amount.
5. **Business Deposit:** The money is deducted from the player's cash and instantly credited to the business account through the **btc-business** integration.

---
*Created by Betiucia Scripts - Empowering your RedM roleplay experience with high-quality btc scripts.*
