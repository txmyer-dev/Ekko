---
capture_type: RESEARCH
timestamp: 2026-02-14 17:41:22 PST
executor: default
agent_completion: Five API free tiers analyzed with strategic keep-or-replace recommendations delivered.
---

# RESEARCH: Five API free tiers analyzed with strategic keep-or-replace recommendations delivered.

**Agent:** default
**Completed:** 2026:02:14:174122

---

## Agent Output

---

SUMMARY: Structured free tier analysis of 5 APIs with gotchas and alternatives identified.

ANALYSIS:

---

## 1. Tomba.io -- Email Finder / Lead Generation API

| Detail | Value |
|---|---|
| **Free tier** | 25 searches + 50 verifications/month (some docs say 50/100 -- assume the lower number) |
| **API access on free?** | YES -- REST API included, 1 API key allowed |
| **Credit card required?** | No |
| **Rate limits** | Not prominently documented beyond monthly caps |
| **Data provided** | Email finder by domain, email verifier, domain search, author finder. 450M+ indexed emails across 76M domains |
| **Commercial use?** | Allowed on free tier (no explicit restriction found) |
| **Gotchas** | Monthly caps are tiny (25 searches is ~1/day). Conflicting docs on exact limits (25 vs 50 searches). Free tier is essentially a trial -- you will hit limits fast for any real workflow |
| **First paid tier** | Starter: $39/mo (1,000 searches, 2,000 verifications) |

**Better free alternative in 2026?**
- **Hunter.io** -- 25 searches/month free, similar capability, more mature ecosystem
- **Snov.io** -- 50 credits/month free, includes email finder + verifier + drip campaigns
- **SocLeads** -- 100 free searches/month (highest free allocation found)

**Verdict:** Tomba's free tier is functional for light testing. For actual use, Snov.io gives you more for free (credits work across finder + verifier + campaigns). SocLeads has the highest raw search count at 100/month.

---

## 2. GNews API (gnews.io) -- News Aggregation

| Detail | Value |
|---|---|
| **Free tier** | 100 requests/day, max 10 articles per request, 1 req/second |
| **Credit card required?** | No |
| **Rate limits** | 1 request/second, 100/day hard cap |
| **Data provided** | News articles from multiple sources globally -- title, description, URL, image, publish date, source info |
| **Historical data** | 30 days only on free tier |
| **Article delay** | 12-hour delay on free tier (not real-time) |
| **Commercial use?** | NO -- free tier is development/testing only. Commercial requires paid plan |
| **Gotchas** | (1) No commercial use on free -- this is the big one. (2) 12-hour article delay. (3) Only 10 articles per request. (4) 30-day historical window. (5) No full article content on free tier |
| **First paid tier** | Essential: EUR 49.99/mo (1,000 req/day, 25 articles/req, real-time, history from 2020, full content) |

**Better free alternative in 2026?**
- **NewsData.io** -- 200 requests/day free, 10 articles/request, real-time, commercial use allowed on free tier
- **NewsAPI.org** -- 100 requests/day free but also blocks commercial use (same gotcha)
- **Mediastack** -- 500 requests/month free with commercial use

**Verdict:** GNews free tier is crippled by the no-commercial-use restriction and 12-hour delay. NewsData.io is the stronger free option -- double the requests, real-time delivery, and allows commercial use. That is the clear winner here.

---

## 3. Finnhub (finnhub.io) -- Stock Market / Financial Data

| Detail | Value |
|---|---|
| **Free tier** | 60 API calls/minute (30 calls/second internal cap) |
| **Credit card required?** | No -- email registration only |
| **Rate limits** | 60/min is generous. No daily cap documented |
| **Data provided** | US real-time stock prices, stock candles (1yr per call), company profiles, basic fundamentals, earnings calendar, market news, forex rates, crypto prices, economic calendar, IPO calendar |
| **WebSocket** | YES -- real-time trade data via WebSocket included on free tier (US stocks) |
| **Historical data** | ~1 year per API call on free (more at lower resolution like monthly) |
| **Commercial use?** | Personal/non-commercial on free tier |
| **Gotchas** | (1) "Financials As Reported" endpoint locked behind paywall. (2) International market data requires paid plan. (3) Some fundamental data endpoints restricted. (4) Free real-time data may have slight delays (few seconds). (5) Non-commercial restriction |
| **First paid tier** | Modular pricing starting ~$49/mo per data bundle |

**Better free alternative in 2026?**
- **Alpha Vantage** -- More built-in technical indicators, but only 25 calls/DAY (much worse rate limits). Better for batch analysis, worse for real-time.
- **FMP (Financial Modeling Prep)** -- 250 requests/day free, good fundamental data, but no free WebSocket
- **Alpaca Markets API** -- Free real-time US stock data (designed for algo trading), very generous limits, but requires brokerage context
- **Yahoo Finance (yfinance)** -- Unofficial, frequently breaks, gets blocked. Avoid.

**Verdict:** Finnhub's free tier is the best in class for financial APIs. 60 calls/min with WebSocket is unmatched at the free level. Alpha Vantage is not even close at 25/day. Keep Finnhub -- there is no better free alternative with this combination of rate limits + real-time + breadth.

---

## 4. AbuseIPDB -- IP Reputation / Abuse Reporting

| Detail | Value |
|---|---|
| **Free tier** | 1,000 checks + reports/day |
| **Verified webmaster tier** | 3,000 requests/day (free, just verify domain ownership) |
| **Credit card required?** | No |
| **Rate limits** | Daily cap based on tier (1K/3K/5K for free/webmaster/supporter) |
| **Data provided** | IP abuse confidence score, report count, country, ISP, usage type, domain, last reported date, report categories |
| **Blacklist endpoint** | Available on free tier (basic, up to 10K IPs) |
| **Bulk check/report** | Not on free tier |
| **Commercial use?** | Commercial use requires Basic plan ($25/mo) or higher |
| **Gotchas** | (1) Commercial use locked behind paywall. (2) Custom/filtered blacklists require paid. (3) abuseConfidenceScore filtering is a subscriber feature. (4) 1,000/day sounds generous but burns fast if you are scanning logs. (5) No bulk operations on free |
| **First paid tier** | Basic: $25/mo (same 1K/day checks but adds commercial license, basic blacklist up to 10K IPs, 100 block checks/day). All paid plans have 30-day free trial |

**Better free alternative in 2026?**
- **VirusTotal API** -- Free tier (500 lookups/day, 4/min), broader threat intel (malware + IP + domain + URL), community-driven
- **IPQualityScore** -- Free tier available, fraud scoring, proxy/VPN/TOR detection
- **Shodan** -- Different angle (device/port scanning), free tier available but limited
- **GreyNoise** -- Free community API for mass-scanning detection, complements AbuseIPDB well

**Verdict:** AbuseIPDB is the gold standard for IP abuse reporting specifically. VirusTotal is broader but different (malware-focused). For pure IP abuse reputation, nothing beats AbuseIPDB's community database at the free tier. The 1,000/day free limit is adequate for most small-to-mid operations. Use the webmaster verification trick to bump to 3,000/day for free.

---

## 5. SendGrid (Twilio SendGrid) -- Transactional Email

| Detail | Value |
|---|---|
| **Free tier** | DISCONTINUED as of May 27, 2025 |
| **Current state** | No free plan exists. Previous free plan was 100 emails/day |
| **Credit card required?** | N/A (no free tier) |
| **Gotchas** | THE ENTIRE FREE TIER IS GONE. This is the biggest gotcha on this list. Anyone planning around SendGrid free in 2026 needs to know it does not exist |
| **First paid tier** | Essentials: $19.95/mo (up to 50K emails/mo) |

**Better free alternatives in 2026 (REQUIRED since SendGrid has no free tier):**

| Service | Free Limit | Daily Cap | Gotchas |
|---|---|---|---|
| **Brevo (ex-Sendinblue)** | 300/day (~9,000/mo) | 300/day | Best overall free tier. 100K contacts. Full transactional + marketing |
| **SMTP2GO** | 1,000/mo | 200/day | Never expires. 5 sender domains. Support downgrades after 14 days |
| **MailerSend** | 500/mo | 100/day | Was 3,000/mo until Oct 2025 -- slashed to 500. "Delivered with MailerSend" branding on free |
| **Postmark** | 100/mo | N/A | Extremely low but excellent deliverability reputation |
| **SendPulse** | 12,000/mo | N/A | Highest volume free tier but less developer-focused |
| **Resend** | 100/day (~3,000/mo) | 100/day | Developer-first, modern API, React Email templates. Great DX |

**Verdict:** SendGrid is dead at free tier. **Brevo** is the strongest replacement at 300/day with no monthly cap catch. For a developer-first experience with a modern API, **Resend** is worth watching (100/day, clean TypeScript SDK). SMTP2GO is the safe boring choice that will never expire.

---

## Strategic Summary Table

| API | Free Tier Status | Usable for Real Work? | Better Free Alt? | Keep or Replace? |
|---|---|---|---|---|
| **Tomba.io** | 25 searches/mo | Barely (testing only) | Snov.io or SocLeads | Replace with Snov.io |
| **GNews** | 100 req/day | Dev only (no commercial, 12hr delay) | NewsData.io | Replace with NewsData.io |
| **Finnhub** | 60 calls/min + WebSocket | YES -- best in class | Nothing comparable | KEEP |
| **AbuseIPDB** | 1,000 checks/day | YES -- solid for small ops | None better for IP abuse | KEEP (verify domain for 3K/day) |
| **SendGrid** | GONE (May 2025) | NO | Brevo (300/day) or Resend | Replace with Brevo |

---

RESULTS: All five APIs researched with exact limits, gotchas, and alternatives documented.

STATUS: Research complete. Two APIs worth keeping (Finnhub, AbuseIPDB), three should be replaced with better free alternatives (Tomba -> Snov.io, GNews -> NewsData.io, SendGrid -> Brevo).

CAPTURE: SendGrid free tier was killed May 2025 -- this is a common trap for anyone referencing older docs. GNews free tier's no-commercial-use clause makes it effectively useless for production. Finnhub at 60 calls/min is the standout winner -- no other financial API comes close at the free tier. AbuseIPDB's webmaster verification trick (free, just verify domain) bumps you from 1K to 3K/day.

NEXT:
1. If you want signup/integration guides for the recommended replacements (Snov.io, NewsData.io, Brevo), I can produce those
2. If any of these are for a specific project, I can map them to your use case and recommend the optimal combination
3. The Finnhub + AbuseIPDB combo gives you financial data + security intelligence as a solid foundation

STORY EXPLANATION:
1. Tomba.io offers a real but tiny free tier (25 searches/month with API access) -- enough to test, not enough to build on
2. GNews has a deceptive free tier -- 100 requests/day sounds decent until you discover the no-commercial-use restriction and 12-hour article delay
3. Finnhub is the clear winner of this group -- 60 API calls per minute with WebSocket real-time data and no credit card, unmatched by any competitor
4. AbuseIPDB provides a solid 1,000 checks/day for free, and verifying domain ownership bumps that to 3,000/day at no cost
5. SendGrid's free tier was completely eliminated in May 2025 -- anyone planning around it needs to pivot immediately
6. The second-order effect of SendGrid's removal is that Brevo and Resend are absorbing developer mindshare, which may accelerate their feature development
7. For news data, NewsData.io at 200 requests/day with commercial use and real-time delivery makes GNews's free tier obsolete
8. The strategic play is to keep Finnhub and AbuseIPDB, replace the other three with superior free alternatives, and avoid building on any tier that restricts commercial use

COMPLETED: Five API free tiers analyzed with strategic keep-or-replace recommendations delivered.
agentId: affe55c (for resuming to continue this agent's work if needed)
<usage>total_tokens: 42590
tool_uses: 28
duration_ms: 166988</usage>

---

## Metadata

**Transcript:** `/home/txmyer/.claude/projects/-home-txmyer/75c149ae-9fed-4c30-9160-5599186369b0.jsonl`
**Captured:** 2026-02-14 17:41:22 PST

---

*This output was automatically captured by UOCS SubagentStop hook.*
