# EDA Insights Report - E-Commerce Funnel Analysis

### Weekly Session Volume
**Observation:** Session volume fluctuates week to week but shows no major structural decline in raw traffic.

**Business Insight:** The conversion drop is NOT caused by fewer visitors coming to the site - traffic is stable. This tells us the problem lives inside the funnel (UX/checkout/payment), not in marketing reach.

**Recommendation:** Marketing spend does not need to increase. Investment should go into fixing on-site conversion friction rather than driving more top-of-funnel traffic.

---
### Traffic Source Conversion
**Observation:** 'Email' converts at 9.2% while 'Paid Ads' converts at only 6.0%.

**Business Insight:** Paid Ads traffic tends to be lower-intent (curiosity clicks), while Email traffic is already familiar with the brand and closer to purchase intent.

**Recommendation:** Reallocate a portion of Paid Ads ad spend toward Email-style channels, or improve landing-page relevance/targeting for Paid Ads campaigns to attract higher-intent users.

---
### Device Type Conversion
**Observation:** Desktop converts at 9.9% vs Mobile at 5.9%, despite Mobile carrying the majority of sessions.

**Business Insight:** Mobile users are dropping off disproportionately, most likely at checkout - suggesting the mobile checkout flow (form fields, payment integration, page load speed) has friction that desktop does not.

**Recommendation:** Prioritize a mobile checkout UX audit: reduce form fields, enable auto-fill/saved cards, add mobile wallets (UPI/Google Pay one-tap), and test page load speed on 4G/3G networks.

---
### Regional Conversion
**Observation:** Regions range from 6.9% to 7.7% conversion.

**Business Insight:** Regional gaps often reflect differences in delivery speed, COD availability, or regional payment preferences rather than product interest.

**Recommendation:** Investigate logistics/delivery SLAs and preferred payment options in the lowest-converting region before assuming it's a demand problem.

---
### Category Conversion
**Observation:** 'Electronics' has the highest conversion (7.5%) while 'Books' has the lowest (6.9%).

**Business Insight:** Lower-converting categories often suffer from higher price uncertainty, sizing/fit issues, or lower trust in product quality shown online.

**Recommendation:** For 'Books', add richer product content (size guides, 360° images, reviews) to reduce pre-purchase hesitation.

---
### Funnel Drop-off
**Observation:** Sessions drop from 13,551 (Add to Cart) to 5,522 (Checkout) - a 59.3% drop, the single largest percentage drop in the funnel.

**Business Insight:** The biggest leak is between adding an item to cart and beginning checkout - meaning many users cart items for later comparison, or shipping cost/login requirements at that step discourage them from continuing immediately.

**Recommendation:** Test showing shipping cost and estimated delivery date directly on the cart page (before checkout) and enable guest checkout to remove login friction.

---
### Purchase Trend
**Observation:** Weekly purchase counts show natural variation without a runaway decline, consistent with stable traffic but a persistently narrow funnel.

**Business Insight:** This confirms the conversion issue is systemic (a constant % leak) rather than a one-time event like an outage or bad campaign.

**Recommendation:** Treat this as a structural UX/process fix, not a one-off incident - prioritize permanent checkout and mobile improvements over short-term promos.

---
### Bounce Rate by Device
**Observation:** Mobile bounce rate is 37.1%, compared to Desktop at 37.6%.

**Business Insight:** Higher mobile bounce suggests either slow mobile page load or a landing experience not optimized for smaller screens, causing users to leave before even viewing a product.

**Recommendation:** Run a mobile page-speed audit (Google PageSpeed Insights / Lighthouse) and simplify the mobile landing page above the fold.

---
### Time on Page
**Observation:** Bounced sessions last only a few seconds, while engaged sessions last significantly longer, as expected.

**Business Insight:** This validates our Bounce_Flag definition and confirms time-on-page is a reliable proxy for engagement depth.

**Recommendation:** Use time-on-page thresholds as an early-warning engagement metric in future dashboards.

---
### Revenue by Category
**Observation:** 'Electronics' generates the highest total revenue (₹5,959,675), even if its conversion rate isn't the highest - driven by higher average order value.

**Business Insight:** Revenue leaders and conversion-rate leaders are not always the same category - both metrics are needed to prioritize correctly.

**Recommendation:** Protect and invest further in 'Electronics' (e.g., dedicated merchandising, faster delivery SLAs) since it disproportionately drives revenue.

---
### Discount Impact
**Observation:** Sessions with a discount convert at 8.2% vs 6.6% without a discount.

**Business Insight:** Discounting has a measurable, positive effect on purchase completion, confirming price sensitivity plays a role in the final decision.

**Recommendation:** Consider targeted, smaller discounts specifically at the checkout-abandonment stage (e.g., a 5% cart-recovery coupon) rather than blanket site-wide discounts.

---
### Payment Method Completion
**Observation:** 'UPI' has the highest checkout-to-purchase completion (69.8%), while 'COD' has the lowest (57.0%).

**Business Insight:** Certain payment methods (like COD or Net Banking) tend to have more failure points (OTP delays, bank redirects, manual confirmation), causing last-minute drop-off.

**Recommendation:** Promote 'UPI'-style instant payment options more prominently at checkout, and investigate/fix friction in the 'COD' payment flow.

---
### Weekend vs Weekday Conversion
**Observation:** Weekday conversion is 7.4% vs weekend at 7.0%.

**Business Insight:** Weekend traffic tends to be more casual/browsing-oriented, while weekday traffic (often during commute/lunch breaks) is more planned and purchase-ready.

**Recommendation:** Schedule performance marketing and push notifications for weekday evenings when intent appears highest, and use weekends for brand/discovery content instead.

---
### New vs Returning Users
**Observation:** Returning users convert at 7.8% vs new users at 6.7%.

**Business Insight:** Returning users trust the platform more and often already know what they want, so they convert at a meaningfully higher rate than first-time visitors.

**Recommendation:** Invest in remarketing (email/push) to bring first-time visitors back for a second session, and strengthen onboarding trust signals (reviews, return policy) for new users.
