---
capture_type: RESEARCH
timestamp: 2026-02-14 18:13:18 PST
executor: default
agent_completion: Three security APIs kept, two book APIs cut. Shodan is highest priority.
---

# RESEARCH: Three security APIs kept, two book APIs cut. Shodan is highest priority.

**Agent:** default
**Completed:** 2026:02:14:181318

---

## Agent Output

SUMMARY: Evaluated 5 deferred APIs for current status, free tier limits, and practical value to a security-focused AI consulting business.

ANALYSIS:

---

## 1. OpenLibrary API (openlibrary.org) -- Book Discovery

- **Auth**: None required. Add User-Agent header for 3x rate boost.
- **Free Tier**: 1 req/sec unauthenticated, 3 req/sec with User-Agent header. Covers API capped at 100 req/5 min.
- **Practical Value**: Zero for security consulting. Book metadata lookup has no monetizable path for your business. Reading lists and "recommended books" features are blog-tier filler.
- **Verdict: CUT.** This is a hobby API. It does not help you make money or deliver security services.

---

## 2. Gutendex (gutendex.com) -- Project Gutenberg Search

- **Auth**: None required.
- **Free Tier**: No published rate limits. No API key needed. Returns 0-32 book objects per query. Self-hostable.
- **Practical Value**: Zero. Public domain book search has absolutely no connection to security consulting, threat intelligence, or any service you would sell. This was a filler pick from the start.
- **Verdict: CUT.** Even more irrelevant than OpenLibrary. Remove from the list entirely.

---

## 3. NVD API (nvd.nist.gov) -- National Vulnerability Database / CVE Data

- **Auth**: Free API key via email registration. No cost.
- **Free Tier**: 5 requests per 30 seconds without key. **50 requests per 30 seconds with free API key.** That is ~100 queries/minute, which is substantial.
- **Practical Value**: HIGH. This is the canonical CVE data source. For a security consultant, this is directly monetizable:
  - Automated vulnerability scanning reports for clients
  - CVE monitoring and alerting for client tech stacks
  - Risk assessment dashboards (pair with client asset inventories)
  - Heartbeat integration: daily CVE digest for critical software
  - Content generation: "New critical CVEs this week" briefings for prospects
- **Second-order effect**: NVD data cross-referenced with Shodan exposure data creates a powerful "your stuff is exposed AND vulnerable" narrative that closes consulting deals.
- **Verdict: KEEP. Priority integration.** This is core to your security consulting value proposition.

---

## 4. URLhaus (urlhaus-api.abuse.ch) -- Malware URL Database

- **Auth**: Free auth key from auth.abuse.ch.
- **Free Tier**: Free under fair use. ~5,000 API requests/month for domains and IPs. Bulk dumps available (active URLs, 30-day, 90-day). 3.6M+ malicious URLs in database.
- **Practical Value**: MODERATE-HIGH for security consulting:
  - Client URL/domain reputation checking
  - Threat intelligence feeds for client networks
  - Incident response: "Is this URL known malicious?" instant lookups
  - Proactive monitoring: check client domains against malware distribution lists
  - Pairs well with NVD: vulnerabilities + active threat URLs = comprehensive threat picture
- **Caveat**: Commercial use may require paid subscription. If you are billing clients for reports that include URLhaus data, review their fair use terms carefully.
- **Verdict: KEEP.** Direct threat intelligence value. The 5K/month free tier is enough to start. Upgrade path exists when you need it.

---

## 5. Shodan (shodan.io) -- Internet Device/Port Scanning

- **Auth**: API key required. Free account gets NO API access.
- **Free Tier**: Free accounts can browse the web UI with limited results but cannot use the API at all. The **Membership** tier is a one-time $49 payment for lifetime API access with 100 query credits/month (each credit = up to 100 results). Paid API plans start at $69/month for 10,000 credits.
- **Practical Value**: HIGHEST of all five. This is the single most powerful tool for security consulting:
  - External attack surface mapping for clients ("here is everything of yours exposed to the internet")
  - Pre-engagement reconnaissance
  - Competitive intelligence: show prospects what their competitors' exposure looks like
  - IoT/OT security assessments
  - The $49 lifetime membership is absurdly good ROI -- 100 queries/month is enough for small consulting engagements
- **Second-order effect**: Shodan + NVD = "Your port 443 is running Apache 2.4.49, which has CVE-2021-41773 (path traversal, CVSS 7.5)." That one sentence sells a remediation engagement.
- **Verdict: KEEP. Buy the $49 membership immediately.** This is the highest-leverage $49 you will spend on your consulting business. It is literally the tool that security consultants use to generate client-facing reports.

---

## Strategic Summary

| API | Verdict | Why |
|-----|---------|-----|
| OpenLibrary | **CUT** | Zero security relevance. Hobby API. |
| Gutendex | **CUT** | Zero security relevance. Public domain books. |
| NVD API | **KEEP** | Core CVE data. Free. Directly monetizable. |
| URLhaus | **KEEP** | Threat intel feeds. Free tier sufficient to start. |
| Shodan | **KEEP** | Attack surface mapping. $49 lifetime. Closes deals. |

**The pattern**: The two book APIs were filler -- they have no path to revenue and no connection to security. The three security APIs form a complementary stack:

- **Shodan** finds what is exposed
- **NVD** finds what is vulnerable
- **URLhaus** finds what is actively being exploited

Together, they create a "detect, assess, prioritize" pipeline that is the foundation of any security consulting engagement. Integrate NVD first (free, highest data volume), buy Shodan membership ($49), and add URLhaus for threat intelligence enrichment.

STATUS: Research complete. 2 APIs cut, 3 APIs recommended for integration.

CAPTURE: NVD free key = 50 req/30sec. Shodan $49 lifetime = 100 query credits/month. URLhaus = 5K req/month free. Book APIs (OpenLibrary, Gutendex) have zero security value -- cut permanently.

NEXT: Register for NVD API key, purchase Shodan $49 lifetime membership, register for URLhaus auth key. Then build integration starting with NVD (highest free volume, most foundational data).

STORY EXPLANATION:
1. Five APIs were deferred from Phase 4 as "nice-to-haves" and needed critical evaluation before integration.
2. OpenLibrary offers book metadata search with modest rate limits but has zero relevance to security consulting -- it is a hobby integration at best.
3. Gutendex provides Project Gutenberg book search with no auth required but is even less relevant than OpenLibrary -- public domain literature has no monetizable path.
4. NVD API is the gold standard for CVE vulnerability data, offers a free API key with generous 50 req/30sec limits, and is directly monetizable through client vulnerability reports.
5. URLhaus tracks 3.6 million malicious URLs with a free tier of 5,000 requests per month -- useful for threat intelligence, domain reputation checks, and incident response.
6. Shodan is the most powerful tool in the set: $49 one-time payment for lifetime API access enables external attack surface mapping that literally sells consulting engagements.
7. The three security APIs form a complementary pipeline: Shodan finds exposure, NVD identifies vulnerabilities, URLhaus tracks active exploitation -- together they power a complete threat assessment workflow.
8. Two book APIs should be permanently cut. The three security APIs should be integrated in order: NVD first (free, foundational), then Shodan ($49 investment), then URLhaus (enrichment layer).

COMPLETED: Three security APIs kept, two book APIs cut. Shodan is highest priority.

Sources:
- [OpenLibrary API Docs](https://openlibrary.org/developers/api)
- [Gutendex](https://gutendex.com/)
- [NVD API Developer Docs](https://nvd.nist.gov/developers/start-here)
- [URLhaus API](https://urlhaus.abuse.ch/api/)
- [Shodan Credits Explained](https://help.shodan.io/the-basics/credit-types-explained)
- [Shodan Account FAQ](https://help.shodan.io/the-basics/account-faq)
agentId: af6f8be (for resuming to continue this agent's work if needed)
<usage>total_tokens: 29700
tool_uses: 12
duration_ms: 95220</usage>

---

## Metadata

**Transcript:** `/home/txmyer/.claude/projects/-home-txmyer/75c149ae-9fed-4c30-9160-5599186369b0.jsonl`
**Captured:** 2026-02-14 18:13:18 PST

---

*This output was automatically captured by UOCS SubagentStop hook.*
