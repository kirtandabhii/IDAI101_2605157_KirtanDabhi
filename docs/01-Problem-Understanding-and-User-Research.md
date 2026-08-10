# Step 1: Problem understanding and user research

**Project:** ScamShield AI, a fraud and scam detection assistant
**Course:** Artificial Intelligence: Real-World Applications and Implications
**Platform:** Google Dialogflow ES

---

## 1. The problem

A fintech company is dealing with rising digital fraud: UPI scams, phishing messages, fake job offers and OTP fraud. Its existing support channels are reactive. A user gets in touch after the money is already gone, by which point the recovery window has usually closed.

What's missing isn't information. Advisories, awareness posters and helpline numbers all exist already. The problem is when and how that information reaches people. A user needs an answer at the moment a suspicious message is sitting on their screen, and in that moment nobody reads a PDF advisory or waits in a call queue. Fraud scripts are written specifically to compress the victim's decision window so that no verification happens.

That points to a conversational tool rather than a webpage or a helpline. The help has to be instant, available at the moment of doubt, and usable by someone who is panicking.

### Why speed decides the outcome

India's national cyber crime helpline (1930) and reporting portal (cybercrime.gov.in) can trigger a hold on a receiving account while the funds are still traceable. That window is short, often described as the golden hour. After about a day the money has usually been layered across several mule accounts and recovery becomes very unlikely.

This one fact shaped the whole architecture. The bot's incident-response path is built for speed rather than completeness. When a user says they have lost money, `Victim.Report` collects two facts (what they did, and how long ago) and then delivers the action list. Everything else waits.

---

## 2. User pain points

Taken from the scenario brief and from documented patterns in Indian digital fraud reporting:

| # | Pain point | Consequence | How ScamShield AI addresses it |
|---|---|---|---|
| P1 | Cannot tell a genuine message from a fraudulent one | Clicks phishing links, pays fake fees | `ScamCheck.Start` then `ScamCheck.Continue` red-flag analysis |
| P2 | Does not know that an OTP must never be shared | Account drained after a single call | `OTP.Guidance`, stated as an unconditional rule |
| P3 | No idea what to do in the minutes after being defrauded | Misses the recovery window entirely | `Victim.Report`, `Victim.BankContacted`, `Report.How` |
| P4 | Does not know where to report, or reports to the wrong place | Complaint never reaches the account-freezing system | `Report.How`, listing 1930, cybercrime.gov.in, bank and FIR in priority order |
| P5 | Unaware that newer fraud types exist (digital arrest, task scams, pig butchering) | Meets a script they have never heard of | 17 scam types in `ScamType.Explain` plus 12 dedicated scenario intents |
| P6 | Shame and fear prevent disclosure | Silence lets losses grow and repeat | `Emotion.Reassure`, which normalises the reaction and moves to action |
| P7 | Awareness fades between incidents | Knows the rules but does not apply them under pressure | `Quiz.Start`, `Quiz.Answer` and `Quiz.Score` as an active-recall loop |
| P8 | Cannot judge whether a link, caller or QR code is safe | Acts on the fraudster's channel of choice | `ScamCheck.Link`, `ScamCheck.UnknownCaller`, `ScamCheck.QRCode` |

---

## 3. Target users and goals

The brief names digital payment users, job seekers, elderly users and students. These are modelled directly in the `@user-group` entity (7 values), which lets `Protect.UserGroup` tailor its advice.

| User group | Main exposure | Goal when opening the bot | What that changed in the build |
|---|---|---|---|
| Digital payment users | UPI collect requests, QR scams, fake refunds | "Is this payment request safe?" | `UPI.Safety` and `ScamCheck.QRCode` state the PIN rule as an absolute rather than a caution |
| Job seekers and freshers | Fake offers, task scams, advance fees | "Should I pay this registration fee?" | `JobOffer.Check` opens with the rule that you never pay an employer |
| Senior citizens | Digital arrest, KYC calls, impersonation | "A police officer called me, what do I do?" | Short sentences, one instruction per line, no jargon. `DigitalArrest.Check` opens with "hang up" |
| Students | Investment and crypto bait, romance scams, loan apps | "Is this scheme genuine?" | `Investment.Check` uses the withdrawal test, which needs no financial literacy |
| Small business owners | Fake customer care, QR payment fraud | "Is this buyer legitimate?" | `ScamCheck.QRCode` covers the OLX and marketplace pattern directly |
| First-time internet users | All of the above | "I don't understand what happened" | `Agent.Capabilities` and `Menu.Main` allow chip-driven navigation with no typing |

### Accessibility decisions that came out of this

Suggestion chips appear on every intent, so a user who cannot phrase a question can still navigate by tapping. That matters most for the two highest-risk groups, senior citizens and first-time internet users.

Fuzzy matching is on for 18 of the 20 entities, with automatic spell correction at agent level. People typing in a panic make spelling errors and the bot should not punish that.

Synonym coverage is deliberately wide: 823 synonyms across 147 reference values, including Indian-English and colloquial forms such as "gpay", "phone pe", "haan", "nahi" and "kirana store owner". Users get understood in the words they actually use.

Every required slot has two prompt variants. If a user doesn't understand the first phrasing, the second attempt is worded differently instead of repeating.

---

## 4. Project scope

### In scope

The bot detects and explains 17 fraud types common to Indian digital payments, and analyses suspicious messages, links, callers and QR codes against a ten-point red-flag framework. For someone who has already lost money or shared credentials, it gives prioritised incident-response actions and points to the official Indian reporting channels along with the evidence each one needs.

It also covers preventive hardening for accounts, devices, identity documents and app permissions, runs a scenario-based awareness quiz, and acknowledges shame or fear before redirecting the user to something concrete they can still control.

### Explicitly out of scope

These boundaries are deliberate, and the `Agent.Identity` intent states them to the user:

ScamShield AI never collects OTPs, PINs, card numbers, passwords or identity documents. A safety bot that asked for those would be teaching users the exact habit it warns against.

It does not access bank accounts, freeze accounts, reverse transactions or file complaints for the user. It gives no legal advice and represents no bank, police force or government body.

It also does not promise recovery. `Recovery.Chargeback` says plainly that recovery depends on speed and is never guaranteed, because false hope is what "recovery agent" scams use to victimise people a second time.

### Ethical design principles applied

The interface itself should do no harm, so the bot never requests sensitive data and says so before being asked. Honesty is preferred over reassurance, which is why recovery odds are stated plainly. `Emotion.Reassure` treats victimisation as the result of engineered scripts rather than user failure, and `Agent.Identity` is upfront that this is a bot with no official authority.

Two further choices follow from the same reasoning. `Human.Escalate` actively routes users out of the bot to real people and official channels rather than trying to contain them. And several intents warn about the second wave of fraud aimed at victims: fake recovery agents and helpline numbers bought as search engine adverts.

---

## 5. Defined chatbot role

> ScamShield AI is a digital fraud prevention assistant. It sits in the gap between a fraudulent message arriving and the user acting on it. It gives a fast, plain-language verdict. If the user has already acted, it turns panic into a correctly ordered response inside the recovery window. Over time it builds scam-recognition habits through active recall.

How that role maps to the build:

| Role function | Conversation design | Intents |
|---|---|---|
| Detect | Multi-turn slot filling gathers channel and message, then red flags via context | `ScamCheck.*` (5 intents, `scamcheck-active` context) |
| Educate | Parameterised explanations driven by `@scam-type` and `@scam-tactic` | `ScamType.*`, `ScamTactic.Explain`, `RedFlags.Explain` |
| Warn | 12 scenario intents matching how users actually describe an incident | `JobOffer.Check`, `DigitalArrest.Check`, `KYC.Check` and 9 others |
| Respond | Urgency-first slot filling, then an ordered action list | `Victim.*` (2 intents, `victim-active` context) |
| Protect | Hardening checklists parameterised by account, device and document | `Account.Protect`, `Device.Secure`, `Documents.Guidance`, `SafetyTips.Get` |
| Reinforce | Context-driven quiz loop with immediate feedback | `Quiz.*` (3 intents, `quiz-active` context) |
| Support | Emotional acknowledgement and escalation to humans | `Emotion.Reassure`, `Human.Escalate` |

---

## 6. Success criteria

| Criterion | Target | Achieved |
|---|---|---|
| Intents | 15 or more | 41 |
| Training phrases per intent | 10 to 12 | 15 to 17 (605 total) |
| Custom entities | 10 or more | 20 (147 values, 823 synonyms) |
| Slot filling enabled | Required parameters | 14 intents, 2 prompt variants each |
| Rich responses | Warnings, tips, quick replies, chips | All 41 intents, using info cards, description cards and suggestion chips |
| Fallback and context handling | Basic | Custom 3-variant fallback plus 3 multi-turn context flows |
| Intent separation | No misclassification | Highest pairwise similarity 0.23; 2 of 605 phrases drift, both entity-protected |
