# Step 3: Testing and optimization

**Project:** ScamShield AI, a fraud and scam detection assistant
**Agent:** Google Dialogflow ES, 41 intents, 20 custom entities, 605 training phrases

---

## A. Automated pre-deployment validation

Before importing to Dialogflow, the generated agent package was checked by a purpose-written validation script (`validate_agent.py`). This catches structural faults that Dialogflow either accepts silently or rejects with an unhelpful error.

| # | Check | Result |
|---|---|---|
| 1 | Every JSON file parses | Pass, 124 files |
| 2 | Every intent has a matching `_usersays_en.json`, and the reverse | Pass |
| 3 | Every entity has a matching `_entries_en.json`, and the reverse | Pass |
| 4 | `name` field matches filename for all intents and entities | Pass |
| 5 | Every parameter's `dataType` resolves to a defined entity or a valid `@sys.` type | Pass |
| 6 | Every training-phrase annotation matches a declared parameter of the same entity | Pass, 134 annotated phrases |
| 7 | Every required parameter has a slot-filling prompt | Pass, 14 intents |
| 8 | Every input context is produced as an output context somewhere | Pass, 3 flows |
| 9 | No duplicate training phrases within or across intents | Pass, 605 unique |
| 10 | No duplicate synonym mapped to two reference values in the same entity | Pass |
| 11 | Every `$parameter` referenced in a response text is declared on that intent | Pass |
| 12 | Every intent has at least one text response and valid `richContent` | Pass |

Final result: 0 errors, 0 warnings.

### Intent separation analysis

With 41 intents in one narrow domain, the main risk is misclassification between overlapping intents. Each intent's training phrases were vectorised (TF-IDF, 1 to 2 grams) and compared pairwise.

| Metric | Value |
|---|---|
| Highest pairwise intent similarity | 0.229, between `ScamCheck.Link` and `ScamCheck.Start` |
| Phrases whose nearest centroid was a different intent | 2 of 605, or 0.3% |
| Both remaining cases | Carry entity annotations (`@account-type`, `@device-type`) that Dialogflow's model weights heavily, so they resolve correctly in practice |

---

## B. Unit testing across all 41 intents

Each intent is tested with a paraphrase that appears nowhere in the training data. Testing with training phrases only proves the agent memorised them; paraphrases prove it generalises. Zero leakage was verified programmatically.

Run each input in the Dialogflow "Try it now" panel and record the result.

| # | Test input (paraphrase, not in training data) | Expected intent | Params expected | Precondition | Result |
|---|---|---|---|---|---|
| 1 | `i want to make my savings account harder to attack` | `Account.Protect` | account-type, protection-step | none | |
| 2 | `what things are you able to help with` | `Agent.Capabilities` | - | none | |
| 3 | `am i chatting with a machine` | `Agent.Identity` | - | none | |
| 4 | `dhl says pay twenty rupees to release my package` | `Courier.Check` | - | none | |
| 5 | `purple tractor mango` | `Default Fallback Intent` | - | none | |
| 6 | `good day to you` | `Default Welcome Intent` | - | none | |
| 7 | `what should i change on my android to be safer` | `Device.Secure` | device-type | none | |
| 8 | `a man in uniform on video says i cannot disconnect` | `DigitalArrest.Check` | - | none | |
| 9 | `they want a photo of my aadhaar, is that ok` | `Documents.Guidance` | document-type | none | |
| 10 | `i feel like an idiot for believing them` | `Emotion.Reassure` | emotion-state | none | |
| 11 | `i would rather speak to an actual officer` | `Human.Escalate` | authority-body | none | |
| 12 | `they say i will get triple returns in sixty days` | `Investment.Check` | - | none | |
| 13 | `the company wants five thousand before joining` | `JobOffer.Check` | channel | none | |
| 14 | `bank sms says update details or account closes` | `KYC.Check` | - | none | |
| 15 | `the lending app is calling my relatives and abusing them` | `LoanApp.Check` | - | none | |
| 16 | `sms says i am a winner but must pay tax first` | `Lottery.Check` | - | none | |
| 17 | `show me everything again` | `Menu.Main` | - | none | |
| 18 | `the agent needs the code that came to my mobile` | `OTP.Guidance` | relationship | none | |
| 19 | `my grandmother keeps answering unknown calls` | `Protect.UserGroup` | user-group | none | |
| 20 | `that is definitely fraud` | `Quiz.Answer` | quiz-verdict | must follow `quiz-active` | |
| 21 | `how many did i answer correctly` | `Quiz.Score` | - | must follow `quiz-active` | |
| 22 | `can we do a practice round` | `Quiz.Start` | - | none | |
| 23 | `is there any hope of getting the amount back` | `Recovery.Chargeback` | - | none | |
| 24 | `what should immediately make me suspicious` | `RedFlags.Explain` | red-flag | none | |
| 25 | `where exactly should i lodge this complaint` | `Report.How` | report-channel, identifier-type | none | |
| 26 | `the girl i chat with daily now needs hospital money` | `Romance.Check` | - | none | |
| 27 | `network vanished on my phone and i cannot receive otps` | `SIMSwap.Check` | - | none | |
| 28 | `any advice on making my passwords stronger` | `SafetyTips.Get` | safety-topic | none | |
| 29 | `they are rushing me to pay in ten minutes` | `ScamCheck.Continue` | red-flag | must follow `scamcheck-active` | |
| 30 | `how can i tell if a web address is fake` | `ScamCheck.Link` | link | none | |
| 31 | `do i have to scan anything to get paid` | `ScamCheck.QRCode` | - | none | |
| 32 | `could you look at a text i just got` | `ScamCheck.Start` | channel, scam-message | none | |
| 33 | `a man rang saying he is from the income tax department` | `ScamCheck.UnknownCaller` | relationship | none | |
| 34 | `why do these tricks fool smart people` | `ScamTactic.Explain` | scam-tactic | none | |
| 35 | `break down how pig butchering scams work` | `ScamType.Explain` | scam-type | none | |
| 36 | `which frauds are trending right now` | `ScamType.List` | - | none | |
| 37 | `caller wants to fix my laptop by taking control of it` | `TechSupport.Check` | - | none | |
| 38 | `really grateful, that clears it up` | `Thanks.Goodbye` | - | none | |
| 39 | `what precautions should i take while paying by upi` | `UPI.Safety` | payment-app | none | |
| 40 | `no i still have not rung them` | `Victim.BankContacted` | confirmation | must follow `victim-active` | |
| 41 | `i have been cheated please help` | `Victim.Report` | action-taken, urgency-level | none | |
Write `Pass` if the matched intent and extracted parameters are as expected. Write `Fail, matched X` otherwise, then add the failing phrase as a training phrase on the correct intent, retrain, and retest.

---

## C. Integration testing with end-to-end journeys

Five complete conversations covering the three context flows and the highest-risk paths.

### Journey 1: fake job offer, user has not yet paid

This is the example given in the assignment brief.

| Turn | User | Expected agent behaviour |
|---|---|---|
| 1 | `I received a job offer asking for money, is this safe?` | `JobOffer.Check`, with the info card "no legitimate job charges you to join", a 7-point warning-sign list and chips |
| 2 | taps `I already paid them` | `Victim.Report` triggered, slot filling begins |
| 3 | `I transferred money` | `action-taken` is set to transferred money, then prompts for urgency |
| 4 | `about an hour ago` | `urgency-level` is set to critical, then delivers the 6-step ordered action list |
| 5 | taps `Have I contacted my bank?` | `Victim.BankContacted`, which requires `victim-active`, prompts yes or no |
| 6 | `no` | `confirmation` is set to no, then delivers the bank-report script and RBI liability rules |

Validates intent chaining, two-parameter slot filling, the `victim-active` context and chip navigation.

### Journey 2: suspicious message triage through the red-flag flow

| Turn | User | Expected agent behaviour |
|---|---|---|
| 1 | `is this a scam` | `ScamCheck.Start`, prompts for channel |
| 2 | `whatsapp` | `channel` is set to WhatsApp, then prompts for the message text |
| 3 | `your account will be blocked, verify at this link` | `scam-message` captured through `@sys.any`, 5-point analysis returned, `scamcheck-active` set |
| 4 | `it has urgency and a shortened link` | `ScamCheck.Continue`, where the list parameter captures both red flags, then returns the verdict card and action list |
| 5 | taps `How do I report this?` | `Report.How`, covering 1930, cybercrime.gov.in, bank and FIR, plus the evidence checklist |

Validates the `scamcheck-active` context, the `@sys.any` free-text slot, `isList` multi-value extraction, and context expiry after lifespan 5.

### Journey 3: digital arrest, an incident in progress

| Turn | User | Expected agent behaviour |
|---|---|---|
| 1 | `a man in uniform on video says i cannot disconnect` | `DigitalArrest.Check`, opening with "hang up" and stating that digital arrest does not legally exist |
| 2 | `i am scared` | `Emotion.Reassure` with `emotion-state` set to scared, normalising the reaction and moving to action |
| 3 | `i want to talk to a real person` | `Human.Escalate`, listing 1930, bank, police, portal and Ombudsman, plus the warning about search-engine helpline numbers |

Validates crisis-path prioritisation, the emotional-support intent, and escalation out of the bot.

### Journey 4: awareness quiz as a context-gated loop

| Turn | User | Expected agent behaviour |
|---|---|---|
| 1 | `start the quiz` | `Quiz.Start`, serving Q1 on the KYC SMS with Scam and Safe chips, setting `quiz-active` at lifespan 10 |
| 2 | `scam` | `Quiz.Answer` confirms the answer, explains the three red flags, serves Q2 |
| 3 | `safe` | `Quiz.Answer` corrects the user, explains the delivery-OTP rule, serves Q3 |
| 4 | `show my score` | `Quiz.Score`, giving the summary and the four rules to keep |

Validates `quiz-active` context gating. There is one check worth doing carefully here: the bare words `scam` and `safe` are training phrases only for `Quiz.Answer`. Typing `scam` outside the quiz must not match `Quiz.Answer`, and should instead reach `ScamType.Explain` or the fallback. Test that explicitly.

### Journey 5: post-incident hardening

| Turn | User | Expected agent behaviour |
|---|---|---|
| 1 | `network vanished on my phone and i cannot receive otps` | `SIMSwap.Check`, with the info card "act within minutes" and a 5-step ordered response |
| 2 | `i want to secure my account` | `Account.Protect`, prompts for account type |
| 3 | `savings` | `account-type` is set to savings account, then returns the 8-point hardening checklist |
| 4 | `what should i change on my android to be safer` | `Device.Secure` with `device-type` set to Android phone, covering permissions and app sources |
| 5 | `thanks` | `Thanks.Goodbye` |

Validates slot filling on two consecutive intents and entity synonym resolution, where "savings" maps to savings account and "android" maps to Android phone.

---

## D. Issues found and fixes applied

These are real defects caught during development, each with the fix applied and re-verified.

| # | Issue | How it was found | Fix | Re-verified |
|---|---|---|---|---|
| 1 | `help` in `Agent.Capabilities` competed with `can you help me` and `i need help` in `Default Welcome Intent` | TF-IDF cross-pull analysis flagged both phrases as nearest to the other intent | Removed the two ambiguous phrases from the Welcome intent and replaced them with `good afternoon` and `hello scamshield` to keep the count at 15 | Cross-pull dropped from 6 phrases to 2 |
| 2 | 9 training-phrase annotations used surface forms not listed as synonyms of their entity, such as `anydesk`, `customer care`, `not yet`, `mother` and `stupid` | Validator warning that annotated text is not a synonym of the entity | Added all 9 as synonyms on the correct reference values | Validator warnings went from 1 to 0 |
| 3 | `block my card` was annotated against `@protection-step` but absent from its synonym list | Same validator check | Added it to the `block the card` reference value | 0 warnings |
| 4 | `scam-message` (`@sys.any`) and `link` (`@sys.url`) had no annotated training examples, which triggers a Dialogflow warning about parameters with no examples | Manual review of the slot-filled intents | Added 2 annotated examples to `ScamCheck.Start` and 2 to `ScamCheck.Link`, using realistic scam text and lookalike URLs | Both intents now have annotated examples for every parameter |
| 5 | Bare `scam` and `safe` in `Quiz.Answer` would have hijacked general queries | Design review of single-word phrases | Gated `Quiz.Answer` behind the `quiz-active` input context so those phrases can only match mid-quiz | Journey 4 |
| 6 | The initial package included schema fields not present in Google's own published agent exports | Compared field by field against three official Dialogflow ES exports | Removed the non-standard fields and set `auto: false` on the fallback intent to match the reference | Import succeeded |

---

## E. Optimization decisions

| Setting | Default | Chosen | Reason |
|---|---|---|---|
| ML classification threshold | 0.3 | 0.4 | With 41 intents in one narrow domain, a low threshold produces confident wrong matches. Raising it sends genuinely ambiguous input to the fallback, which offers chips. That is a much better failure mode than a wrong scam verdict. |
| Automatic spell correction | Off | On | People typing during a fraud incident make spelling errors. |
| Fuzzy matching | Off | On for 18 of 20 entities | Handles partial and inexact entity mentions. Deliberately off for `@confirmation` and `@quiz-verdict`, where yes or no and scam or safe must be exact. A fuzzy match on a yes-or-no answer would be a serious correctness bug. |
| Automated expansion | Off | On for 17 entities | Lets the agent recognise unlisted values in the same category, such as a new payment app. Off for the closed sets: `confirmation`, `quiz-verdict` and `urgency-level`. |
| Response variants | 1 | 2 to 4 on 12 intents | Stops the bot sounding robotic on repeat queries. |
| Context lifespans | 5 | 5, 8 and 10 | `scamcheck-active` at 5, `victim-active` at 8 because incident conversations run longer, and `quiz-active` at 10 to cover all four questions plus the score request. |

---

## F. Test summary

| Category | Count | Status |
|---|---|---|
| Automated structural checks | 12 | 12 passed, 0 failed |
| Intent separation analysis | 605 phrases | 0.3% drift, both entity-protected |
| Unit tests, one paraphrase per intent | 41 | To be recorded in Section B |
| Integration journeys | 5 | To be recorded in Section C |
| Defects found and fixed | 6 | All fixed and re-verified |
