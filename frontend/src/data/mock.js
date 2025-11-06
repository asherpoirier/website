// Mock data for Flux IPTV

export const subscriptionPlans = [
  {
    id: 1,
    name: "1 Month",
    price: 10,
    duration: "month",
    popular: false,
    whmcsLink: "https://your-whmcs-domain.com/cart.php?a=add&pid=1"
  },
  {
    id: 2,
    name: "3 Months",
    price: 25,
    duration: "3 months",
    popular: false,
    whmcsLink: "https://your-whmcs-domain.com/cart.php?a=add&pid=2"
  },
  {
    id: 3,
    name: "6 Months",
    price: 45,
    duration: "6 months",
    popular: true,
    whmcsLink: "https://your-whmcs-domain.com/cart.php?a=add&pid=3"
  },
  {
    id: 4,
    name: "12 Months",
    price: 80,
    duration: "year",
    popular: false,
    savings: "Save $40",
    whmcsLink: "https://your-whmcs-domain.com/cart.php?a=add&pid=4"
  }
];

export const features = [
  {
    id: 1,
    title: "10,000+ Live Channels",
    description: "Access thousands of channels from around the world in HD and 4K quality",
    icon: "Tv"
  },
  {
    id: 2,
    title: "20,000+ Movies",
    description: "Extensive library of movies across all genres, updated regularly",
    icon: "Film"
  },
  {
    id: 3,
    title: "5,000+ TV Series",
    description: "Binge-watch your favorite series with complete seasons available",
    icon: "Clapperboard"
  },
  {
    id: 4,
    title: "99.9% Uptime",
    description: "Reliable service with minimal downtime and maximum stability",
    icon: "Shield"
  },
  {
    id: 5,
    title: "Wide Device Compatibility",
    description: "Works on Smart TV, Android, iOS, Fire Stick, MAG, and more",
    icon: "Smartphone"
  },
  {
    id: 6,
    title: "Fast Zap Technology",
    description: "Lightning-fast channel switching for seamless viewing experience",
    icon: "Zap"
  }
];

export const testimonials = [
  {
    id: 1,
    name: "Michael Rodriguez",
    role: "Sports Enthusiast",
    content: "Best IPTV service I've ever used! The channel selection is incredible and the streaming quality is always top-notch. Haven't experienced any buffering issues.",
    rating: 5
  },
  {
    id: 2,
    name: "Sarah Johnson",
    role: "Movie Lover",
    content: "The movie library is massive! I can always find what I want to watch. The 4K quality is stunning and the service is super reliable.",
    rating: 5
  },
  {
    id: 3,
    name: "David Chen",
    role: "Family User",
    content: "Perfect for my whole family. Everyone can watch what they love on different devices. The support team is also very responsive on Telegram.",
    rating: 5
  },
  {
    id: 4,
    name: "Emma Williams",
    role: "International Viewer",
    content: "Finally found a service with channels from my home country! The variety is amazing and the fast zap feature makes switching channels so smooth.",
    rating: 5
  }
];

export const faqs = [
  {
    id: 1,
    question: "What devices are compatible with Flux IPTV?",
    answer: "Flux IPTV works on a wide range of devices including Smart TVs (Samsung, LG, Sony), Android devices, iOS (iPhone/iPad), Amazon Fire Stick, MAG boxes, Android TV boxes, and most streaming devices. You can also use it on Windows and Mac computers."
  },
  {
    id: 2,
    question: "How does the 1-day free trial work?",
    answer: "Simply sign up for our free trial and you'll get 24 hours of full access to all channels, movies, and TV series. No credit card required for the trial. After the trial ends, you can choose a subscription plan that works best for you."
  },
  {
    id: 3,
    question: "What internet speed do I need?",
    answer: "For standard definition (SD), we recommend at least 5 Mbps. For HD quality, 10 Mbps is recommended, and for 4K content, you'll need at least 25 Mbps for the best experience."
  },
  {
    id: 4,
    question: "Can I use my subscription on multiple devices?",
    answer: "Yes! Your subscription allows you to use the service on multiple devices. However, the number of simultaneous connections depends on your plan. Contact us for more details on multi-device options."
  },
  {
    id: 5,
    question: "How do I get support if I have issues?",
    answer: "Our support team is available via Telegram for quick assistance. Simply click the support button on our website to connect with us. We typically respond within minutes during business hours."
  },
  {
    id: 6,
    question: "Do you offer refunds?",
    answer: "We offer a satisfaction guarantee. If you're not happy with the service within the first 7 days, contact our support team and we'll process a refund. We recommend trying our free trial first to ensure the service meets your needs."
  },
  {
    id: 7,
    question: "Is the service legal?",
    answer: "Flux IPTV operates as a legitimate streaming service provider. We work with content providers to deliver quality entertainment. However, we recommend checking your local laws and regulations regarding IPTV services."
  },
  {
    id: 8,
    question: "How often is content updated?",
    answer: "Our content library is updated daily with new movies, TV series episodes, and live channels. We constantly expand our offerings to provide the latest entertainment options."
  }
];

export const telegramSupportUrl = "https://t.me/customcloudtv";
export const freeTrialWhmcsUrl = "https://your-whmcs-domain.com/cart.php?a=add&pid=trial";