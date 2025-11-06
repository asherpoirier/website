import React, { useState } from 'react';
import { Button } from '../components/ui/button';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '../components/ui/card';
import { Badge } from '../components/ui/badge';
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from '../components/ui/accordion';
import { Tv, Film, Clapperboard, Shield, Smartphone, Zap, Star, MessageCircle, Check, Sparkles } from 'lucide-react';
import { subscriptionPlans, features, testimonials, faqs, telegramSupportUrl, freeTrialWhmcsUrl } from '../data/mock';

const iconMap = {
  Tv: Tv,
  Film: Film,
  Clapperboard: Clapperboard,
  Shield: Shield,
  Smartphone: Smartphone,
  Zap: Zap
};

export const Home = () => {
  const [hoveredPlan, setHoveredPlan] = useState(null);

  const handleFreeTrial = () => {
    window.open(freeTrialWhmcsUrl, '_blank');
  };

  const handleSubscribe = (whmcsLink) => {
    window.open(whmcsLink, '_blank');
  };

  const handleTelegramSupport = () => {
    window.open(telegramSupportUrl, '_blank');
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-950 via-slate-900 to-slate-950">
      {/* Header */}
      <header className="fixed top-0 left-0 right-0 z-50 bg-slate-950/80 backdrop-blur-md border-b border-slate-800">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <img 
              src="https://customer-assets.emergentagent.com/job_6ba45c1d-d99b-48ed-93f3-1f3a2b9f4763/artifacts/ppgulcfs_ChatGPT%20Image%20Nov%206%2C%202025%2C%2012_54_38%20AM.png" 
              alt="Flux IPTV Logo" 
              className="h-12 w-auto"
            />
          </div>
          <nav className="hidden md:flex items-center space-x-8">
            <a href="#features" className="text-slate-300 hover:text-white transition-colors">Features</a>
            <a href="#pricing" className="text-slate-300 hover:text-white transition-colors">Pricing</a>
            <a href="#testimonials" className="text-slate-300 hover:text-white transition-colors">Reviews</a>
            <a href="#faq" className="text-slate-300 hover:text-white transition-colors">FAQ</a>
            <Button onClick={handleTelegramSupport} variant="outline" size="sm" className="border-slate-700 hover:bg-slate-800">
              <MessageCircle className="w-4 h-4 mr-2" />
              Support
            </Button>
          </nav>
          <Button onClick={handleFreeTrial} className="bg-gradient-to-r from-orange-500 to-pink-500 hover:from-orange-600 hover:to-pink-600 text-white shadow-lg">
            <Sparkles className="w-4 h-4 mr-2" />
            Free Trial
          </Button>
        </div>
      </header>

      {/* Hero Section */}
      <section className="pt-32 pb-20 px-4">
        <div className="container mx-auto text-center">
          <Badge className="mb-6 bg-orange-500/10 text-orange-400 border-orange-500/20 hover:bg-orange-500/20">
            1 Day Free Trial Available
          </Badge>
          <h1 className="text-5xl md:text-7xl font-bold text-white mb-6 tracking-tight">
            Premium IPTV Service
            <br />
            <span className="bg-gradient-to-r from-orange-400 via-pink-400 to-purple-400 bg-clip-text text-transparent">
              Unlimited Entertainment
            </span>
          </h1>
          <p className="text-xl text-slate-400 mb-8 max-w-2xl mx-auto">
            Experience the future of television with 10,000+ live channels, 20,000+ movies, and 5,000+ TV series. All in stunning HD and 4K quality.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
            <Button 
              onClick={handleFreeTrial}
              size="lg" 
              className="bg-gradient-to-r from-orange-500 to-pink-500 hover:from-orange-600 hover:to-pink-600 text-white text-lg px-8 py-6 shadow-2xl shadow-orange-500/30 hover:shadow-orange-500/50 transition-all"
            >
              Start Free Trial
            </Button>
            <Button 
              onClick={() => document.getElementById('pricing').scrollIntoView({ behavior: 'smooth' })}
              size="lg" 
              variant="outline" 
              className="border-slate-700 hover:bg-slate-800 text-lg px-8 py-6"
            >
              View Pricing
            </Button>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="py-20 px-4 bg-slate-900/50">
        <div className="container mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-bold text-white mb-4">
              Why Choose Flux IPTV?
            </h2>
            <p className="text-slate-400 text-lg max-w-2xl mx-auto">
              Industry-leading features that deliver the best streaming experience
            </p>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {features.map((feature) => {
              const IconComponent = iconMap[feature.icon];
              return (
                <Card 
                  key={feature.id} 
                  className="bg-slate-800/50 border-slate-700 hover:bg-slate-800/80 transition-all duration-300 hover:shadow-xl hover:shadow-orange-500/10 hover:border-orange-500/30 group"
                >
                  <CardHeader>
                    <div className="w-12 h-12 bg-gradient-to-br from-orange-500/20 to-pink-500/20 rounded-lg flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                      <IconComponent className="w-6 h-6 text-orange-400" />
                    </div>
                    <CardTitle className="text-white">{feature.title}</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <CardDescription className="text-slate-400">
                      {feature.description}
                    </CardDescription>
                  </CardContent>
                </Card>
              );
            })}
          </div>
        </div>
      </section>

      {/* Pricing Section */}
      <section id="pricing" className="py-20 px-4">
        <div className="container mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-bold text-white mb-4">
              Simple, Transparent Pricing
            </h2>
            <p className="text-slate-400 text-lg max-w-2xl mx-auto">
              Choose the plan that fits your needs. All plans include full access to our entire content library.
            </p>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 max-w-7xl mx-auto">
            {subscriptionPlans.map((plan) => (
              <Card 
                key={plan.id}
                onMouseEnter={() => setHoveredPlan(plan.id)}
                onMouseLeave={() => setHoveredPlan(null)}
                className={`relative bg-slate-800/50 border-slate-700 transition-all duration-300 ${
                  plan.popular 
                    ? 'ring-2 ring-orange-500 shadow-2xl shadow-orange-500/20 transform scale-105' 
                    : 'hover:border-orange-500/50'
                } ${hoveredPlan === plan.id ? 'transform scale-105 shadow-xl' : ''}`}
              >
                {plan.popular && (
                  <div className="absolute -top-4 left-1/2 transform -translate-x-1/2">
                    <Badge className="bg-gradient-to-r from-orange-500 to-pink-500 text-white border-0 shadow-lg">
                      Most Popular
                    </Badge>
                  </div>
                )}
                {plan.savings && (
                  <div className="absolute -top-4 right-4">
                    <Badge className="bg-green-500 text-white border-0 shadow-lg">
                      {plan.savings}
                    </Badge>
                  </div>
                )}
                <CardHeader>
                  <CardTitle className="text-white text-2xl">{plan.name}</CardTitle>
                  <div className="mt-4">
                    <span className="text-5xl font-bold text-white">${plan.price}</span>
                    <span className="text-slate-400 ml-2">/{plan.duration}</span>
                  </div>
                </CardHeader>
                <CardContent className="space-y-3">
                  <div className="flex items-start space-x-2">
                    <Check className="w-5 h-5 text-green-400 flex-shrink-0 mt-0.5" />
                    <span className="text-slate-300 text-sm">10,000+ Live Channels</span>
                  </div>
                  <div className="flex items-start space-x-2">
                    <Check className="w-5 h-5 text-green-400 flex-shrink-0 mt-0.5" />
                    <span className="text-slate-300 text-sm">20,000+ Movies</span>
                  </div>
                  <div className="flex items-start space-x-2">
                    <Check className="w-5 h-5 text-green-400 flex-shrink-0 mt-0.5" />
                    <span className="text-slate-300 text-sm">5,000+ TV Series</span>
                  </div>
                  <div className="flex items-start space-x-2">
                    <Check className="w-5 h-5 text-green-400 flex-shrink-0 mt-0.5" />
                    <span className="text-slate-300 text-sm">HD & 4K Quality</span>
                  </div>
                  <div className="flex items-start space-x-2">
                    <Check className="w-5 h-5 text-green-400 flex-shrink-0 mt-0.5" />
                    <span className="text-slate-300 text-sm">99.9% Uptime</span>
                  </div>
                  <div className="flex items-start space-x-2">
                    <Check className="w-5 h-5 text-green-400 flex-shrink-0 mt-0.5" />
                    <span className="text-slate-300 text-sm">24/7 Support</span>
                  </div>
                </CardContent>
                <CardFooter>
                  <Button 
                    onClick={() => handleSubscribe(plan.whmcsLink)}
                    className={`w-full ${
                      plan.popular 
                        ? 'bg-gradient-to-r from-orange-500 to-pink-500 hover:from-orange-600 hover:to-pink-600 shadow-lg' 
                        : 'bg-slate-700 hover:bg-slate-600'
                    } text-white`}
                  >
                    Subscribe Now
                  </Button>
                </CardFooter>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* Testimonials Section */}
      <section id="testimonials" className="py-20 px-4 bg-slate-900/50">
        <div className="container mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-bold text-white mb-4">
              Trusted by Thousands
            </h2>
            <p className="text-slate-400 text-lg max-w-2xl mx-auto">
              See what our customers have to say about their experience
            </p>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {testimonials.map((testimonial) => (
              <Card key={testimonial.id} className="bg-slate-800/50 border-slate-700 hover:bg-slate-800/80 transition-all hover:shadow-lg">
                <CardHeader>
                  <div className="flex items-center space-x-1 mb-2">
                    {[...Array(testimonial.rating)].map((_, i) => (
                      <Star key={i} className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                    ))}
                  </div>
                  <CardTitle className="text-white text-lg">{testimonial.name}</CardTitle>
                  <CardDescription className="text-slate-500">{testimonial.role}</CardDescription>
                </CardHeader>
                <CardContent>
                  <p className="text-slate-300 text-sm leading-relaxed">{testimonial.content}</p>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* FAQ Section */}
      <section id="faq" className="py-20 px-4">
        <div className="container mx-auto max-w-4xl">
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-bold text-white mb-4">
              Frequently Asked Questions
            </h2>
            <p className="text-slate-400 text-lg">
              Everything you need to know about Flux IPTV
            </p>
          </div>
          <Accordion type="single" collapsible className="space-y-4">
            {faqs.map((faq) => (
              <AccordionItem 
                key={faq.id} 
                value={`item-${faq.id}`}
                className="bg-slate-800/50 border border-slate-700 rounded-lg px-6 hover:bg-slate-800/80 transition-colors"
              >
                <AccordionTrigger className="text-white hover:text-orange-400 transition-colors text-left">
                  {faq.question}
                </AccordionTrigger>
                <AccordionContent className="text-slate-400 leading-relaxed">
                  {faq.answer}
                </AccordionContent>
              </AccordionItem>
            ))}
          </Accordion>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 px-4 bg-gradient-to-r from-slate-900 via-slate-800 to-slate-900">
        <div className="container mx-auto text-center">
          <h2 className="text-4xl md:text-5xl font-bold text-white mb-6">
            Ready to Get Started?
          </h2>
          <p className="text-slate-400 text-lg mb-8 max-w-2xl mx-auto">
            Try Flux IPTV risk-free with our 1-day free trial. No credit card required.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
            <Button 
              onClick={handleFreeTrial}
              size="lg" 
              className="bg-gradient-to-r from-orange-500 to-pink-500 hover:from-orange-600 hover:to-pink-600 text-white text-lg px-8 py-6 shadow-2xl shadow-orange-500/30"
            >
              <Sparkles className="w-5 h-5 mr-2" />
              Start Your Free Trial
            </Button>
            <Button 
              onClick={handleTelegramSupport}
              size="lg" 
              variant="outline" 
              className="border-slate-700 hover:bg-slate-800 text-lg px-8 py-6"
            >
              <MessageCircle className="w-5 h-5 mr-2" />
              Contact Support
            </Button>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-slate-950 border-t border-slate-800 py-12 px-4">
        <div className="container mx-auto">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8 mb-8">
            <div>
              <img 
                src="https://customer-assets.emergentagent.com/job_6ba45c1d-d99b-48ed-93f3-1f3a2b9f4763/artifacts/ppgulcfs_ChatGPT%20Image%20Nov%206%2C%202025%2C%2012_54_38%20AM.png" 
                alt="Flux IPTV Logo" 
                className="h-10 w-auto mb-4"
              />
              <p className="text-slate-400 text-sm">
                Premium IPTV service delivering unlimited entertainment worldwide.
              </p>
            </div>
            <div>
              <h3 className="text-white font-semibold mb-4">Quick Links</h3>
              <ul className="space-y-2">
                <li><a href="#features" className="text-slate-400 hover:text-white transition-colors text-sm">Features</a></li>
                <li><a href="#pricing" className="text-slate-400 hover:text-white transition-colors text-sm">Pricing</a></li>
                <li><a href="#testimonials" className="text-slate-400 hover:text-white transition-colors text-sm">Testimonials</a></li>
                <li><a href="#faq" className="text-slate-400 hover:text-white transition-colors text-sm">FAQ</a></li>
              </ul>
            </div>
            <div>
              <h3 className="text-white font-semibold mb-4">Support</h3>
              <ul className="space-y-2">
                <li>
                  <button onClick={handleTelegramSupport} className="text-slate-400 hover:text-white transition-colors text-sm flex items-center">
                    <MessageCircle className="w-4 h-4 mr-2" />
                    Telegram Support
                  </button>
                </li>
                <li>
                  <button onClick={handleFreeTrial} className="text-slate-400 hover:text-white transition-colors text-sm">
                    Free Trial
                  </button>
                </li>
              </ul>
            </div>
            <div>
              <h3 className="text-white font-semibold mb-4">Service Stats</h3>
              <ul className="space-y-2 text-sm">
                <li className="text-slate-400">10,000+ Channels</li>
                <li className="text-slate-400">20,000+ Movies</li>
                <li className="text-slate-400">5,000+ TV Series</li>
                <li className="text-slate-400">99.9% Uptime</li>
              </ul>
            </div>
          </div>
          <div className="border-t border-slate-800 pt-8 text-center">
            <p className="text-slate-400 text-sm">
              © 2025 Flux IPTV. All rights reserved.
            </p>
          </div>
        </div>
      </footer>
    </div>
  );
};