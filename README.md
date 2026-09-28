# Gotta Track ’Em All

### Snap. Discover. Collect.

**Gotta Track ’Em All (GTAE)** is an AI-powered Pokémon card collection and tracking application built during the **Le Wagon AI Software Development Bootcamp**.

The application allows collectors to photograph Pokémon cards, identify them using AI-powered image recognition, retrieve card information and pricing data, and manage their personal collection.

## Features

* 📸 **AI-powered card recognition** — Upload a photo of a Pokémon card and use the OpenAI API to identify it.
* 🔎 **Card information** — View details including the card's artist, set, attacks, abilities and rarity.
* 💰 **Pricing data** — Retrieve card pricing information from external APIs.
* 📚 **Collection management** — Save cards to your personal collection and keep track of cards you own.
* ⭐ **Favorites** — Mark cards as favorites for quick access.
* 🔐 **User authentication** — Full registration and login functionality using Devise.
* ✉️ **Automated email** — Password-reset and welcome emails.
* ⚡ **Asynchronous processing** — Background jobs handle longer-running operations without blocking the user interface.
* 📱 **Responsive design** — Adaptive layouts for both mobile and desktop.
* 🎨 **Dynamic UI components** — Interactive carousels, lightboxes and accordions built with JavaScript/Stimulus.

## Responsive Design Examples:
**Homepage from a large view port:**
<img width="2499" height="1667" alt="screenshot from 28-09-2026-40" src="https://github.com/user-attachments/assets/b578b0b1-9e87-4b7f-9811-842c647bda00" />

**Homepage from mobile view port**
<img width="787" height="1250" alt="screenshot from 28-09-2026-39" src="https://github.com/user-attachments/assets/297aab0e-effe-4fc7-b56d-2c78143c670d" />


## How It Works

1. **Snap** — The user uploads a photo of one or more Pokémon cards.
2. **Discover** — The image is sent through an AI recognition pipeline using the OpenAI API.
3. **Identify** — The application determines which Pokémon card has been photographed.
4. **Retrieve** — Card information and pricing data are retrieved from external APIs.
5. **Collect** — The user can save the card to their personal collection or mark it as a favorite.

## Tech Stack

### Backend

* Ruby
* Ruby on Rails
* PostgreSQL
* Active Record
* Devise
* Solid Queue / background jobs

### Frontend

* ERB
* Stimulus JS
* JavaScript
* CSS
* TailwindCSS

### APIs & Services

* OpenAI API — image recognition and AI functionality
* TCGdex — Pokémon card data and pricing
* Cloudinary — image hosting and management

### Development

* Git
* GitHub CLI
* REST APIs

## AI Integration

A central part of GTAE is the integration of AI into a conventional full-stack Rails application.

The OpenAI API is used to process uploaded Pokémon card images and identify the card. The resulting information is then used to retrieve additional card data and pricing information, allowing the AI component to become part of a larger application workflow rather than functioning as a standalone feature.

## Background Processing

Some operations can take longer to complete, particularly when communicating with external APIs. GTAE uses asynchronous background jobs to move these operations away from the main request cycle.

This allows the application to remain responsive while card information and pricing data are being retrieved and processed.

## Authentication & User Accounts

GTAE uses **Devise** to provide user authentication and account management.

Users can:

* Create an account
* Log in and out
* Reset their password
* Receive automated welcome emails
* Maintain a personal collection

## Project Background

Gotta Track ’Em All was started as part of the **Le Wagon AI Software Development Bootcamp**. The app was left in an incomplete state at the end of the boot camp so I decided to polish and deploy it.

The project provided an opportunity to apply full-stack development concepts to a real-world application, combining a Ruby on Rails backend with a JavaScript frontend, relational database design, third-party APIs, background processing and AI-powered functionality.

The project was also developed using Git and GitHub workflows, including feature branches and pull requests.

> **Note:** The original version of GTAE used the TCGdex API for card data and pricing. TCGdex is no longer available, so some pricing functionality may no longer operate as originally intended.

## What I Learned

Building GTAE gave me practical experience with:

* Object-oriented programming with Ruby and Rails
* Relational database design with PostgreSQL
* Active Record
* API integration
* AI and multimodal image recognition
* Background job processing
* Authentication and user management
* Responsive UI development
* JavaScript and Stimulus
* Git/GitHub collaboration and development workflows
* Connecting multiple services into a complete full-stack application
* SMTP Configuration to a custom domain
* Deployment using Docker images and Kamal
  
