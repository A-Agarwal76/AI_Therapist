# AI Therapist 🧠🎙️

A cutting-edge, comprehensive ecosystem for mental health support. The **AI Therapist** combines a beautiful multilingual voice frontend with an advanced backend powered by **Retrieval-Augmented Generation (RAG)** and **Group Relative Policy Optimization (GRPO)** to deliver highly accurate, empathetic, and culturally aware therapeutic sessions.

---

## 📌 Project Overview

The AI Therapist is designed to simulate a warm, human-like therapy experience. It is built upon a highly optimized stack, divided into frontend and backend ecosystems that work in seamless harmony.

### Technology Stack & Component Table

| Layer | Component | Technology | Purpose |
| :--- | :--- | :--- | :--- |
| **Frontend** | Mobile Voice App | Flutter, Dart | Provides the cross-platform UI, voice recording, and text input interface. |
| **Translation & TTS** | Voice Engine | Sarvam AI API | Translates user speech to English for the LLM, and speaks translated output aloud. |
| **API Gateway** | Data Router | HTTP / FastAPI | Routes frontend requests securely to the local Intelligence Core. |
| **RAG Engine** | Knowledge Base | LangChain, ChromaDB | Ingests `.parquet` medical data, handles dense vector retrieval to ground answers. |
| **Intelligence Core** | GRPO-Tuned LLM | Unsloth, TRL, HuggingFace | Provides highly structured, empathetic, and strictly medically-grounded responses. |

---

## 🏗️ High-Level Design (HLD)

The AI Therapist operates as a unified pipeline where the frontend mobile application seamlessly integrates with our advanced AI backend to provide efficient therapy. Below is the overarching architecture.

![HLD Architecture](d:/AI_Therapist/assets/hld_architecture.png)

### 🧠 How GRPO and RAG Enable Efficient Therapy

The backend system is the heart of the AI Therapist. It utilizes the powerful synergy of **RAG** and **GRPO** to ensure the therapy is both safe and highly effective.

| Core Technology | Functionality & Integration | Impact on Therapy |
| :--- | :--- | :--- |
| **RAG (Medical Grounding)** | Employs ChromaDB to retrieve facts from validated CBT and psychiatric texts. | Prevents dangerous hallucinations; ensures all advice is deeply grounded in science. |
| **GRPO (Behavior Tuning)** | Reinforcement learning (RLHF) optimizes the LLM's conversational style and empathy. | Punishes robotic or verbose text; rewards concise, supportive, and non-judgmental tone. |
| **The Synergy** | RAG provides the *content* (the medical book) and GRPO provides the *delivery* (bedside manner). | Yields therapy that is factually accurate, emotionally resonant, and computationally efficient. |

---

## ⚙️ Low-Level Design (LLD)

Below is the detailed data flow illustrating exactly how a patient's voice input is transformed, processed by the RAG and GRPO engines, and returned as a spoken therapeutic response.

![LLD Flowchart](d:/AI_Therapist/assets/lld_architecture.png)

### 1. Mobile Chatbot Flow (Frontend)
1. **Input Processing**: The user speaks in their native language (e.g., Hindi, Spanish). The Flutter app captures this via device speech-to-text.
2. **Translation Layer**: The `SarvamService` translates the native text to English instantly to maximize the backend LLM's reasoning capabilities.
3. **API Dispatch**: The translated text is sent to the backend Intelligence Core via HTTP POST.
4. **Response Handling**: The generated therapeutic response is translated back into the user's native language.
5. **Vocalization**: The app triggers the Sarvam TTS engine to speak the response aloud in a warm, natural voice.

### 2. RAG & GRPO Generation Flow (Backend)
1. **Data Ingestion (`Rag_1.py`)**: 
   - Medical `.parquet` files are processed and split using `CharacterTextSplitter`.
   - Embeddings are generated using HuggingFace `sentence-transformers` and persisted in ChromaDB.
2. **Context Retrieval**: 
   - The user's query is vectorized. A `similarity_search(query, k=3)` fetches the most relevant therapeutic guidelines.
3. **GRPO Inference Pipeline (`GRPO.py` / `Rag_final.py`)**:
   - The context and the query are merged into a strict system prompt.
   - The GRPO fine-tuned HuggingFace model (optimized with `BitsAndBytesConfig` 4-bit quantization) processes the prompt.
   - The output is highly constrained by its RLHF training to ensure it is brief, conversational, and deeply supportive.

---

## 🚀 Getting Started

### 1. Run the Mobile App (Flutter)
1. Navigate to the `chatbot - Copy/` directory.
2. Update your API keys in `lib/secrets.dart`:

| Variable Name | Purpose | Example / Details |
| :--- | :--- | :--- |
| `APIKEY` | Backend/Gemini Access | Required for LLM generation |
| `SARVAM_API_KEY` | Translation & Voice TTS | Required for 16+ multilingual support |

3. Fetch dependencies: `flutter pub get`
4. Launch the app: `flutter run`

### 2. Run the Intelligence Backend (Python)
1. Navigate to the `AI_therapist_main/` directory.
2. Install the necessary Python packages:
   ```bash
   pip install -r requirements.txt
   ```
3. Build the Medical Vector Database:
   ```bash
   python Rag_1.py
   ```
4. Start the RAG+GRPO Engine (CLI or Streamlit UI):
   ```bash
   streamlit run streamlit_app.py
   # Or for terminal interaction:
   python Rag_final.py
   ```
