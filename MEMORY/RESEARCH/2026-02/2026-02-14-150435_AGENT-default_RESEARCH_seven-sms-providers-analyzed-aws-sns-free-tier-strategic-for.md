---
capture_type: RESEARCH
timestamp: 2026-02-14 15:04:35 PST
executor: default
agent_completion: Seven SMS providers analyzed, AWS SNS free tier strategic for immediate testing.
---

# RESEARCH: Seven SMS providers analyzed, AWS SNS free tier strategic for immediate testing.

**Agent:** default
**Completed:** 2026:02:14:150435

---

## Agent Output

---

📋 SUMMARY: Comprehensive comparison of 7 SMS providers for personal notification system in February 2026

🔍 ANALYSIS:
**Critical Finding:** Email-to-SMS gateways are dead - AT&T shut down June 2025, Verizon late 2024, T-Mobile December 2024. Major carriers killed this due to spam/smishing attacks.

**A2P 10DLC Reality:** Even hobby projects and personal use now require A2P 10DLC registration for US SMS. The only exception is Sole Proprietor registration ($4 brand + $15 campaign vetting + $2/month), but it supports only 1 phone number and 1 campaign. Setup takes up to 4 weeks.

**Cost Breakdown:** Services range from $0.004 (Telnyx) to $0.06 (Textbelt) per message, plus A2P registration fees where applicable. AWS SNS offers 100 free US SMS/month in free tier.

⚡ ACTIONS:
- Searched Twilio pricing and A2P requirements
- Researched AWS SNS capabilities for low-volume use
- Investigated Textbelt current status and pricing
- Verified email-to-SMS gateway shutdown status
- Compared Vonage/Nexmo vs Twilio pricing
- Analyzed Telnyx as Twilio alternative
- Confirmed ntfy.sh does not support SMS delivery

✅ RESULTS:

## 1. TWILIO
**Cost per message:** $0.0079 (outbound/inbound)  
**Setup time:** 2-4 weeks (A2P 10DLC required)  
**Reliability:** Industry standard, excellent  
**Registration:** A2P 10DLC mandatory - Sole Proprietor: $4 brand + $15 campaign vetting + $2/month campaign fee  
**Carrier fees:** $0.003 per registered message segment (carriers like Verizon)  
**API simplicity:** YES - single curl command possible  
```bash
curl -X POST -d "Body=Message" -d "From=$TWILIO_NUMBER" -d "To=$TO_NUMBER" \
  "https://api.twilio.com/2010-04-01/Accounts/$TWILIO_ACCOUNT_SID/Messages" \
  -u "$TWILIO_ACCOUNT_SID:$TWILIO_AUTH_TOKEN"
```
**Best for:** Production systems, high reliability requirements

## 2. AWS SNS
**Cost per message:** $0.00645 (US), $0.0023-$0.50 (international)  
**Setup time:** 1-2 hours (AWS account setup + IAM)  
**Reliability:** Very high (AWS infrastructure)  
**Registration:** 10DLC required - Regular campaign $10/month OR Low-volume campaign $2/month  
**Free tier:** 100 SMS/month to US numbers  
**Default spending quota:** $1.00/month (can request increase)  
**API simplicity:** Moderate - requires AWS SDK or signed requests  
**Best for:** Already in AWS ecosystem, need free tier for testing

## 3. TEXTBELT
**Cost per message:** $0.06 ($3 per 50 texts)  
**Setup time:** Immediate  
**Reliability:** Medium (last outage Nov 18, 2025)  
**Registration:** None required  
**Free tier:** 1 free text per day  
**API simplicity:** YES - extremely simple  
**Open source version:** Available (uses email-to-SMS, no longer reliable)  
**Paid version:** Uses direct carrier connections  
**Best for:** Quick prototypes, no registration tolerance  
**Second-order concern:** 8x more expensive than competitors - not sustainable at scale

## 4. EMAIL-TO-SMS GATEWAYS
**Status:** DEAD - DO NOT USE  
**AT&T:** Shut down June 17, 2025  
**Verizon (vtext.com):** Shut down late 2024  
**T-Mobile (tmomail.net):** Failed Nov 2024, completely dead Dec 14, 2024  
**Reason:** Spam/smishing attacks exploited email spoofing  
**Reliability:** Zero - service no longer exists  
**Best for:** Nothing - this option is extinct

## 5. VONAGE (formerly NEXMO)
**Cost per message:** $0.00809 (outbound), $0.00649 (inbound) US  
**Phone number rental:** $0.90/month (local), $1.75/month (toll-free)  
**Setup time:** 2-4 weeks (A2P 10DLC required)  
**Reliability:** High  
**Registration:** A2P 10DLC mandatory  
**API simplicity:** YES - REST API, single curl command  
**Best for:** Slightly cheaper per-message than Twilio  
**Strategic note:** "Cheaper than Twilio" but requires same A2P overhead

## 6. TELNYX
**Cost per message:** $0.004 (both outbound/inbound US) - LOWEST COST  
**Setup time:** 2-4 weeks (A2P 10DLC required)  
**Reliability:** High  
**Registration:** A2P 10DLC mandatory (passes fees at cost, no markup)  
**API simplicity:** YES - clean REST API  
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{"from":"+1234567890","to":"+1234567890","text":"Hello"}' \
  https://api.telnyx.com/v2/messages
```
**Pay-as-you-go:** No monthly minimums  
**Best for:** Cost-conscious developers, simple API, no Telnyx fees on A2P  
**Strategic advantage:** Half the cost of Twilio, reputation for easier low-volume setup

## 7. NTFY.SH
**SMS support:** NONE  
**Purpose:** Push notifications to phones/desktops via HTTP  
**Not applicable** for SMS delivery  
**Alternative use:** Could trigger SMS via another service

📊 STATUS:
**Email-to-SMS:** Extinct (all carriers shut down)  
**A2P 10DLC:** Required for all US 10DLC SMS from applications  
**Hobbyist options:** Sole Proprietor registration available but limited (1 number, 1 campaign)  
**Setup timeline:** 2-4 weeks for A2P registration across all major providers

📁 CAPTURE:
**Key strategic insight:** The SMS landscape has fundamentally changed. Carriers killed the "free" email-to-SMS route and mandated A2P 10DLC registration even for hobby projects. This creates a registration barrier (4 weeks, $21 initial + $2/month minimum) that's unavoidable for US SMS delivery.

**Second-order effects:**
1. Textbelt's simplicity comes at 8x price premium - viable for low-volume prototyping but not sustainable
2. AWS SNS free tier (100 SMS/month) is strategic for testing before committing to A2P registration
3. Telnyx offers best $/message but requires same A2P overhead as Twilio
4. All major providers converge on same registration requirement - differentiation is purely price/API quality

**Three moves ahead:**
- Start with AWS SNS free tier for immediate testing (100 SMS/month, no A2P needed initially)
- Prototype notification routing architecture while waiting for A2P approval
- Plan Telnyx as production provider (lowest cost, clean API) after A2P registration completes

➡️ NEXT:
**Immediate action:** Use AWS SNS free tier for prototype (100 SMS/month, $0 cost)  
**Parallel track:** Start Sole Proprietor A2P 10DLC registration ($4 + $15 = $19 one-time, $2/month)  
**Production plan:** Switch to Telnyx after A2P approval ($0.004/message, cleanest API)  
**Backup option:** Textbelt for immediate testing ($0.06/message, no registration)

**Strategic decision tree:**
- Volume < 100 SMS/month → AWS SNS (free tier)
- Need immediate SMS, no time for A2P → Textbelt ($0.06/msg)
- Production, cost-sensitive → Telnyx ($0.004/msg after A2P)
- Already in AWS ecosystem → AWS SNS ($0.00645/msg)
- Need maximum reliability → Twilio ($0.0079/msg)

📖 STORY EXPLANATION:
1. The SMS landscape underwent tectonic shift in 2024-2025 when all major carriers killed email-to-SMS gateways due to spam exploitation
2. A2P 10DLC registration became mandatory even for personal hobby projects, creating 4-week setup barrier and $21 initial + $2/month minimum cost
3. AWS SNS emerges as strategic testing ground with 100 free US SMS per month, allowing prototype development while A2P registration processes
4. Textbelt offers registration-free immediate SMS at premium pricing ($0.06/msg vs industry $0.004-$0.008), viable for prototypes but not sustainable at scale
5. Telnyx provides lowest per-message cost ($0.004) with clean API and no markup on A2P fees, making it optimal for production after registration completes
6. Vonage prices slightly better than Twilio but both require identical A2P overhead, differentiating only on marginal per-message costs
7. All major providers converge on same registration requirements, shifting competition from "ease of entry" to "cost efficiency at scale"
8. Strategic path: AWS SNS free tier for immediate testing → Sole Proprietor A2P registration ($19 one-time) → Telnyx for production ($0.004/msg lowest cost)

🎯 COMPLETED: Seven SMS providers analyzed, AWS SNS free tier strategic for immediate testing.

---

**Sources:**
- [Twilio A2P 10DLC Pricing](https://help.twilio.com/articles/1260803965530-What-pricing-and-fees-are-associated-with-the-A2P-10DLC-service-)
- [Twilio SMS Pricing US](https://www.twilio.com/en-us/sms/pricing/us)
- [AWS SNS SMS Pricing](https://aws.amazon.com/sns/sms-pricing/)
- [AWS SNS Pricing Overview](https://aws.amazon.com/sns/pricing/)
- [Textbelt Homepage](https://textbelt.com)
- [Textbelt FAQ](https://textbelt.com/faq/)
- [Email-to-SMS Gateway Shutdown](https://www.smseagle.eu/2025/05/08/no-support-for-email-to-text-from-att-verizon-and-t-mobile-what-are-your-alternatives/)
- [AT&T Email-to-Text Discontinued](https://textbolt.com/migration/att/)
- [Vonage API Pricing](https://www.vonage.com/communications-apis/pricing/)
- [Twilio vs Vonage Comparison](https://www.courier.com/integrations/compare/twilio-vs-vonage)
- [Telnyx 10DLC Fees](https://support.telnyx.com/en/articles/5634625-10dlc-fees-and-charges)
- [Telnyx SMS Pricing](https://telnyx.com/pricing/messaging)
- [Telnyx Send Message API](https://developers.telnyx.com/docs/messaging/messages/send-message)
- [ntfy.sh Homepage](https://ntfy.sh/)
- [ntfy GitHub](https://github.com/binwiederhier/ntfy)
- [Twilio Send SMS with curl](https://www.twilio.com/en-us/blog/send-sms-twilio-shell-script-curl)
- [Textbelt Pricing RapidAPI](https://rapidapi.com/r4chestnut/api/textbelt-sms/pricing)
- [A2P 10DLC Hobby Projects Hacker News](https://news.ycombinator.com/item?id=36002045)
- [A2P 10DLC Requirements Hacker News](https://news.ycombinator.com/item?id=41717873)
- [Top SMS Providers 2026](https://knock.app/blog/the-top-sms-providers-for-developers)
agentId: a25b179 (for resuming to continue this agent's work if needed)
<usage>total_tokens: 34685
tool_uses: 14
duration_ms: 133281</usage>

---

## Metadata

**Transcript:** `/home/txmyer/.claude/projects/-home-txmyer/ec008850-e3a8-4d6d-87f5-1e8cd510ec77.jsonl`
**Captured:** 2026-02-14 15:04:35 PST

---

*This output was automatically captured by UOCS SubagentStop hook.*
