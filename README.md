# ScamShield AI: fraud and scam detection assistant

An AI-powered conversational assistant built with Google Dialogflow ES. It helps users identify scams before they lose money, and respond correctly within the recovery window if they already have.

**CRS:** Artificial Intelligence
**Course:** Artificial Intelligence: Real-World Applications and Implications
**Assessment:** Summative Assessment, Task 1, Scenario 1
**Student:** Kirtan Dabhi
**Candidate Registration Number:** 2605167
**School:** Udgam School for Children

---

## Live chatbot

| Link | What it is |
|---|---|
| [Open ScamShield AI, styled demo](https://kirtandabhii.github.io/IDAI101_2605157_KirtanDabhi/) | GitHub Pages page embedding Dialogflow Messenger. Renders the info cards, description cards and suggestion chips. Use this one. |
| [Open ScamShield AI, Web Demo](https://bot.dialogflow.com/857731a1-7c86-4bcf-9d45-5ea58d017089) | Dialogflow's own hosted Web Demo. Plain-text fallback, always available. |

Try: `is this a scam`, `I received a job offer asking for money, is this safe?`, `should I share my OTP`, `I have already lost money`, `start the quiz`

---

## 1. Project overview

### The problem

A fintech company faces rising digital fraud through UPI scams, phishing, fake job offers and OTP fraud. Its support channels are reactive: users make contact after the money is gone, once the recovery window has closed.

What's missing isn't information, since advisories and helplines already exist. The problem is timing. A user needs an answer at the exact moment a suspicious message is on their screen, and fraud scripts are written to compress that decision window so no verification happens.

### The solution

ScamShield AI sits in that gap and does four things.

It detects, analysing a message, link, caller or QR code against a ten-point red-flag framework and returning a plain-language verdict. It educates, explaining 17 fraud types as a five-stage anatomy along with the psychological tactics behind them. When a user has already lost money it responds, turning panic into a correctly ordered action list inside the golden hour, while an account freeze is still possible. And it reinforces what the user learns through a scenario-based quiz built on active recall, so awareness survives between incidents.

### Why a chatbot is the right tool

The help has to be instant, conversational and available at the moment of doubt. A PDF advisory or a call queue fails that test. Suggestion chips on every intent mean a user who cannot phrase a question can still navigate by tapping, which matters most for the two highest-risk groups: senior citizens and first-time internet users.

### Ethical design

The interface itself should do no harm, so the bot never requests OTPs, PINs, card numbers or documents, and says so before being asked. A safety bot that asked for those would be teaching users the exact habit it warns against.

Honesty is preferred over reassurance. `Recovery.Chargeback` states plainly that recovery depends on speed and is never guaranteed, because false hope is what "recovery agent" scams use to victimise people a second time.

`Emotion.Reassure` treats victimisation as the result of engineered scripts rather than user failure, and `Agent.Identity` is upfront that this is a bot with no official authority. `Human.Escalate` then routes users out to real people and official channels rather than trying to contain them.

---

## 2. Agent at a glance

| Metric | Requirement | Delivered |
|---|---|---|
| Intents | 15 or more | 41 |
| Training phrases | 10 to 12 per intent | 605 total, 15 to 17 per intent |
| Custom entities | 10 or more | 20 |
| Entity reference values | not specified | 147 |
| Entity synonyms | not specified | 823 |
| Intents with slot filling | required params | 14, each with 2 prompt variants |
| Context flows | basic handling | 3: `scamcheck-active`, `victim-active`, `quiz-active` |
| Rich responses | warnings, tips, quick replies, chips | all 41 intents |
| Fallback | basic | custom, 3 response variants plus navigation chips |

Agent settings: default language `en`, time zone `Asia/Kolkata`, ML classification threshold `0.4`, automatic spell correction on, no webhook required.

---

## 3. Intents

41 intents across eight functional groups. An asterisk marks a required parameter, meaning slot filling is active.

#### Core & navigation (5)

| Intent | Purpose | Phrases | Parameters | Context | Rich response |
|---|---|---|---|---|---|
| `Default Welcome Intent` | Greets the user, states what the bot does and that nothing is stored | 15 | none | none | chips, description |
| `Default Fallback Intent` | Handles unrecognised input with three varied recovery messages and chips | 0 | none | none | chips |
| `Agent.Capabilities` | Lists the six capability areas of the assistant | 15 | none | none | chips, description |
| `Agent.Identity` | Discloses that this is a bot with no official authority and never asks for credentials | 15 | none | none | chips |
| `Menu.Main` | Returns the user to the top-level chip menu from anywhere | 15 | none | none | chips |

#### Scam detection (5)

| Intent | Purpose | Phrases | Parameters | Context | Rich response |
|---|---|---|---|---|---|
| `ScamCheck.Start` | Entry point for analysing a suspicious message; collects channel and message text | 17 | `channel`\*, `scam-message`\* | out: `scamcheck-active` | chips, description |
| `ScamCheck.Continue` | Follow-up that captures one or more red flags and issues the verdict | 15 | `red-flag`\*&nbsp;(list) | in: `scamcheck-active`<br>out: `scamcheck-active` | chips, description, info |
| `ScamCheck.Link` | Teaches how to judge a URL without opening it | 17 | `link` | none | chips, description |
| `ScamCheck.UnknownCaller` | Verifies a caller by the role they claimed to hold | 15 | `relationship`\* | none | chips, description |
| `ScamCheck.QRCode` | States the absolute rule that scanning plus PIN always sends money out | 15 | none | none | chips, description, info |

#### Fraud education (4)

| Intent | Purpose | Phrases | Parameters | Context | Rich response |
|---|---|---|---|---|---|
| `ScamType.List` | Presents the 17-type scam library grouped into five families | 15 | none | none | chips, description |
| `ScamType.Explain` | Explains any named scam type as a five-stage anatomy | 15 | `scam-type`\* | none | chips, description |
| `ScamTactic.Explain` | Explains the psychological lever behind a scam and how to break it | 15 | `scam-tactic`\* | none | chips, description |
| `RedFlags.Explain` | The ten-point red-flag checklist common to almost every scam | 15 | `red-flag` | none | chips, description |

#### Scenario-specific checks (12)

| Intent | Purpose | Phrases | Parameters | Context | Rich response |
|---|---|---|---|---|---|
| `OTP.Guidance` | Unconditional guidance that an OTP is never shared, with the common lies listed | 15 | `relationship` | none | chips, description, info |
| `UPI.Safety` | Safe UPI habits, collect-request handling and transaction limits | 15 | `payment-app` | none | chips, description |
| `JobOffer.Check` | Fake job and task-scam detection; the no-fee red line | 15 | `channel` | none | chips, description, info |
| `KYC.Check` | Handles the highest-volume fraud SMS in India | 15 | none | none | chips, description |
| `LoanApp.Check` | Illegal lending-app harassment; frames the user as victim, not offender | 15 | none | none | chips, description, info |
| `Investment.Check` | Investment and pig-butchering scams; the withdrawal test | 15 | none | none | chips, description, info |
| `TechSupport.Check` | Remote-access and screen-sharing scams | 15 | none | none | chips, description, info |
| `Lottery.Check` | Prize and lucky-draw scams; paying to receive is always fraud | 15 | none | none | chips, description, info |
| `DigitalArrest.Check` | Digital arrest scam; states clearly it has no basis in Indian law | 15 | none | none | chips, description, info |
| `Romance.Check` | Romance and matrimonial scams, including the investment variant | 15 | none | none | chips, description |
| `Courier.Check` | Parcel, customs and delivery-fee scams | 15 | none | none | chips, description |
| `SIMSwap.Check` | Treats sudden signal loss as an emergency; five-step ordered response | 15 | none | none | chips, description, info |

#### Incident response (4)

| Intent | Purpose | Phrases | Parameters | Context | Rich response |
|---|---|---|---|---|---|
| `Victim.Report` | Emergency triage; collects what was done and how long ago, then the action list | 16 | `action-taken`\*, `urgency-level`\*, `scam-type` | out: `victim-active` | chips, description, info |
| `Victim.BankContacted` | Follow-up confirming bank contact; supplies the dispute script and RBI liability rules | 15 | `confirmation`\* | in: `victim-active`<br>out: `victim-active` | chips, description |
| `Recovery.Chargeback` | Honest assessment of recovery odds; warns about recovery-agent re-victimisation | 15 | none | none | chips, description |
| `Report.How` | Official Indian reporting routes in priority order, plus the evidence checklist | 15 | `report-channel`, `identifier-type` | none | chips, description |

#### Protection & prevention (5)

| Intent | Purpose | Phrases | Parameters | Context | Rich response |
|---|---|---|---|---|---|
| `Account.Protect` | Account hardening checklist by account type | 15 | `account-type`\*, `protection-step` | none | chips, description |
| `Device.Secure` | Device hardening; permissions, app sources and compromise recovery | 15 | `device-type`\* | none | chips, description |
| `Documents.Guidance` | Identity-document sharing rules and what to do if already shared | 15 | `document-type`\* | none | chips, description |
| `SafetyTips.Get` | Practical guidance across nine digital-safety topics | 15 | `safety-topic`\* | none | chips, description |
| `Protect.UserGroup` | Protection plan tailored to a specific vulnerable group | 15 | `user-group`\* | none | chips, description |

#### Awareness quiz (3)

| Intent | Purpose | Phrases | Parameters | Context | Rich response |
|---|---|---|---|---|---|
| `Quiz.Start` | Starts the awareness quiz and serves question 1 | 15 | none | out: `quiz-active` | chips |
| `Quiz.Answer` | Scores the answer, explains the reasoning and serves the next question | 15 | `quiz-verdict`\* | in: `quiz-active`<br>out: `quiz-active` | chips |
| `Quiz.Score` | Closes the quiz with the summary and the four rules to keep | 15 | none | in: `quiz-active` | chips, description |

#### Support & closing (3)

| Intent | Purpose | Phrases | Parameters | Context | Rich response |
|---|---|---|---|---|---|
| `Emotion.Reassure` | Acknowledges shame, fear or anger and redirects to controllable action | 15 | `emotion-state`\* | none | chips, description |
| `Human.Escalate` | Routes the user to real humans and official bodies | 15 | `authority-body` | none | chips, description |
| `Thanks.Goodbye` | Closes with the single rule that stops most scams | 15 | none | none | chips |
### Conversation flows and context handling

Three multi-turn flows use input and output contexts so that follow-up intents can only match in the right situation.

```
scamcheck-active  (lifespan 5)
  ScamCheck.Start ──> ScamCheck.Continue
  collects channel + message      captures one or more red flags (list param)

victim-active  (lifespan 8)
  Victim.Report ──> Victim.BankContacted
  collects action + urgency       confirms bank contact, gives dispute script

quiz-active  (lifespan 10)
  Quiz.Start ──> Quiz.Answer (loops) ──> Quiz.Score
```

Context gating also prevents a real bug. The bare words `scam` and `safe` are training phrases for `Quiz.Answer`. Without the `quiz-active` context they would hijack general queries. With it, they only match mid-quiz.

---

## 4. Entities

20 custom entity types. Fuzzy matching is deliberately off for `@confirmation` and `@quiz-verdict`, since a fuzzy match on a yes-or-no or scam-or-safe answer would be a correctness bug.
| # | Entity | Purpose | Values | Synonyms | Fuzzy | Auto-expand | Example values | Used by |
|---|---|---|---|---|---|---|---|---|
| 1 | `@account-type` | Account being hardened or frozen | 6 | 22 | yes | yes | savings account, current account, credit card account, digital wallet, etc. | 1 intent |
| 2 | `@action-taken` | What the victim has already done; decides which steps matter | 9 | 55 | yes | yes | shared OTP, transferred money, clicked a link, installed an app, etc. | 1 intent |
| 3 | `@authority-body` | Official bodies the user may want to reach | 8 | 36 | yes | yes | Cyber Crime Portal, my bank, police, RBI, etc. | 1 intent |
| 4 | `@channel` | Where the suspicious contact arrived | 11 | 52 | yes | yes | SMS, WhatsApp, email, phone call, etc. | 2 intents |
| 5 | `@confirmation` | Strict yes/no for follow-up questions | 2 | 24 | no | no | yes, no | 1 intent |
| 6 | `@device-type` | Device being secured | 6 | 29 | yes | yes | Android phone, iPhone, Windows PC, Mac, etc. | 1 intent |
| 7 | `@document-type` | Identity documents a fraudster may request | 9 | 36 | yes | yes | Aadhaar, PAN card, bank statement, debit card, etc. | 1 intent |
| 8 | `@emotion-state` | The user's emotional state, for an appropriate response | 5 | 36 | yes | yes | scared, embarrassed, angry, confused, etc. | 1 intent |
| 9 | `@identifier-type` | The artefact being reported (number, link, UPI ID, QR) | 6 | 29 | yes | yes | phone number, email address, UPI ID, website link, etc. | 1 intent |
| 10 | `@payment-app` | UPI apps and payment rails the user may name | 8 | 29 | yes | yes | Google Pay, PhonePe, Paytm, BHIM, etc. | 1 intent |
| 11 | `@protection-step` | Specific protective action requested | 8 | 40 | yes | yes | freeze the account, block the card, change passwords, enable two factor, etc. | 1 intent |
| 12 | `@quiz-verdict` | Strict scam/safe for quiz answers | 2 | 19 | no | no | scam, safe | 1 intent |
| 13 | `@red-flag` | The ten fraud indicators, used as a list parameter | 10 | 66 | yes | yes | artificial urgency, request for OTP, suspicious link, advance fee request, etc. | 2 intents |
| 14 | `@relationship` | Who the fraudster claimed to be | 8 | 46 | yes | yes | bank official, police officer, delivery agent, customer care agent, etc. | 2 intents |
| 15 | `@report-channel` | Routes for filing a complaint | 5 | 27 | yes | yes | helpline 1930, online portal, bank customer care, police station, etc. | 1 intent |
| 16 | `@safety-topic` | Preventive-education topics | 9 | 46 | yes | yes | password security, two factor authentication, safe UPI habits, spotting phishing, etc. | 1 intent |
| 17 | `@scam-tactic` | Psychological levers used by fraudsters | 7 | 39 | yes | yes | impersonation, fear, greed, urgency, etc. | 1 intent |
| 18 | `@scam-type` | The 17 fraud families the bot can explain | 17 | 117 | yes | yes | UPI scam, phishing, fake job offer, OTP fraud, etc. | 2 intents |
| 19 | `@urgency-level` | How time-critical the incident is; drives the emergency path | 4 | 27 | yes | no | critical, high, medium, low | 1 intent |
| 20 | `@user-group` | Vulnerable groups, for tailored protection advice | 7 | 48 | yes | yes | student, senior citizen, job seeker, small business owner, etc. | 1 intent |
### Slot filling

14 intents collect required parameters before responding. Each one has two prompt variants, so a user who doesn't understand the first phrasing gets a differently worded second attempt instead of a repeat.

Example, `Victim.Report`:

| Parameter | Entity | Required | Prompt 1 | Prompt 2 |
|---|---|---|---|---|
| `action-taken` | `@action-taken` | yes | "First, tell me what has already happened. Did you share an OTP, transfer money, click a link...?" | "What did you actually do? Knowing this decides which steps matter most." |
| `urgency-level` | `@urgency-level` | yes | "How long ago did this happen, within the last hour, today, or longer ago?" | "Is money already gone, or are you trying to prevent it?" |
| `scam-type` | `@scam-type` | no | none | none |

`ScamCheck.Continue` uses an `isList` parameter, so a user can report several red flags in one sentence. "it has urgency and a shortened link" captures both.

---

## 5. Rich responses

Every intent returns a text response plus a Dialogflow Messenger custom payload using `richContent`.

An `info` block gives a high-severity warning banner, such as "Scanning + PIN = money leaves you". A `description` block holds multi-line guidance, checklists and ordered steps, like the ten red flags or the six emergency actions. A `chips` block provides suggestion chips for tap-only navigation, such as "I have already lost money" or "Start the quiz".

Text responses also carry multiple variants on 12 intents, so the bot doesn't repeat itself word for word.

Payload structure:

```json
{
  "richContent": [
    [ { "type": "info", "title": "...", "subtitle": "..." } ],
    [ { "type": "description", "title": "...", "text": ["...", "..."] } ],
    [ { "type": "chips", "options": [ { "text": "..." } ] } ]
  ]
}
```

---

## 6. Integration details

| Integration | Purpose | Status |
|---|---|---|
| Dialogflow Messenger | Embedded in `index.html`, served by GitHub Pages. Renders info cards, description cards and suggestion chips. | Enabled |
| Dialogflow Web Demo | Hosted public URL, guaranteed availability, plain-text rendering. | Enabled |
| Webhook / fulfillment | Not used. The agent is fully static, so it needs no server and cannot leak user data. | Not required |

The landing page (`index.html`) embeds the agent with:

```html
<script src="https://www.gstatic.com/dialogflow-console/fast/messenger/bootstrap.js?v=1"></script>
<df-messenger
  intent="WELCOME"
  chat-title="ScamShield AI"
  agent-id="857731a1-7c86-4bcf-9d45-5ea58d017089"
  language-code="en">
</df-messenger>
```

---

## 7. Deployment instructions

### Prerequisites

A Google account. No billing, no Cloud project setup and no server are required, since the Dialogflow ES Trial edition is enough.

### Step 1: create the agent

1. Go to https://dialogflow.cloud.google.com, which is the Dialogflow ES console.
2. Click Create Agent, name it `ScamShield-AI`, set language to English (en) and time zone to (GMT+5:30) Asia/Kolkata, then click Create.

### Step 2: import the agent

1. Click the gear icon beside the agent name, then open the Export and Import tab.
2. Click Restore from ZIP, upload `agent/ScamShield-AI.zip`, type `RESTORE` and confirm.
3. Wait for the Agent training spinner to finish. This takes 2 to 5 minutes for 605 training phrases.

### Step 3: verify

In Try it now, confirm that `hi` matches Welcome, `is this message a scam` matches `ScamCheck.Start`, `I have already lost money` matches `Victim.Report`, and `blue elephant sandwich` reaches the fallback. The full test protocol is in [`docs/02-Testing-and-Optimization-Log.md`](docs/02-Testing-and-Optimization-Log.md).

### Step 4: enable the integrations

Go to Integrations, enable Web Demo and copy the `bot.dialogflow.com` URL. Then enable Dialogflow Messenger and copy the `agent-id` from the embed code.

### Step 5: publish the page

1. Push this repository to GitHub.
2. Go to Settings, then Pages. Set Source to "Deploy from a branch", branch `main`, folder `/ (root)`. Save.
3. Wait a minute or two, then open `https://yourusername.github.io/your-repo-name/`.
4. Paste that URL and the Web Demo URL into the Live chatbot table at the top of this README.

GitHub Pages only offers `/ (root)` or `/docs` as the folder, which is why `index.html` sits at the repository root rather than in a subfolder.

---

## 8. Repository structure

```
.
├── index.html                                       the live page, served by GitHub Pages
├── README.md                                        this file
├── Preview locally.command                          double-click to test the page locally
├── agent/
│   └── ScamShield-AI.zip                            importable Dialogflow ES agent
└── docs/
    ├── 01-Problem-Understanding-and-User-Research.md   Step 1
    └── 02-Testing-and-Optimization-Log.md              Step 3
```

---

## 9. Safety information sources

All guidance in the agent is India-specific and verified against official sources.

| Resource | Purpose |
|---|---|
| 1930 | National Cyber Crime Helpline, 24x7 and toll free. First call for any financial fraud. |
| cybercrime.gov.in | National Cyber Crime Reporting Portal, run by MHA and I4C |
| sancharsaathi.gov.in | Report fraud calls and SMS senders, and check which SIMs are registered on your ID |
| cms.rbi.org.in | RBI Ombudsman, a free escalation route if a bank does not resolve a complaint in 30 days |
| 1909 | SMS short code for forwarding fraud messages |

---

## 10. Limitations and future work

The agent has no webhook, so it cannot look up a live case status, check a URL against a threat database, or file a complaint for the user. It runs in English only, which is a real limitation given that the highest-risk users often prefer Hindi or a regional language. The quiz questions are fixed rather than randomised, and the score is not kept across sessions.

Four things would address most of that. Multilingual support can be added through Dialogflow's built-in language settings. A fulfillment webhook could check URLs against a phishing feed in real time. Knowledge Connectors would let new fraud advisories be ingested without retraining. And sentiment analysis could escalate distressed users to `Human.Escalate` automatically.
