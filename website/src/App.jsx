import React, { useState, useEffect } from "react";
import { motion, useAnimation } from "framer-motion";
import { FaLeaf, FaShoppingCart, FaGift, FaGlobe } from "react-icons/fa";
import { Link } from "react-router-dom";
import { useInView } from "react-intersection-observer";

export default function LandingPage() {
  return (
    <div className="bg-black text-white overflow-x-hidden">
      <Navbar />
      <HeroSection />
      <VisionSection />
      <FeaturesSection />
      <TestimonialsSection />
      <CallToActionSection />
      <Footer />
    </div>
  );
}

function Navbar() {
  const [isScrolled, setIsScrolled] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      if (window.scrollY > 50) {
        setIsScrolled(true);
      } else {
        setIsScrolled(false);
      }
    };
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  return (
    <nav
      className={`fixed top-0 w-full z-50 flex items-center justify-between p-6 ${
        isScrolled ? "bg-black bg-opacity-90" : "bg-transparent"
      } transition-all duration-300`}
    >
      {/* Logo with Glint Effect */}
      <motion.div
        whileHover={{ scale: 1.1 }}
        className="text-3xl font-bold tracking-wide text-green-400 cursor-pointer relative overflow-hidden"
      >
        GreenBite
        <div className="absolute inset-0 overflow-hidden">
          <div className="glint-effect"></div>
        </div>
      </motion.div>
      <div className="hidden md:flex space-x-8">
        <Link to="#hero" className="hover:text-green-300 transition">Home</Link>
        <Link to="#vision" className="hover:text-green-300 transition">Our Vision</Link>
        <Link to="#features" className="hover:text-green-300 transition">Features</Link>
        <Link to="#testimonials" className="hover:text-green-300 transition">Testimonials</Link>
        <Link to="#contact" className="hover:text-green-300 transition">Contact</Link>
      </div>
      <motion.button
        whileHover={{ scale: 1.05 }}
        className="px-5 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 transition relative overflow-hidden"
      >
        Sign Up
        <div className="absolute inset-0 overflow-hidden">
          <div className="glint-effect"></div>
        </div>
      </motion.button>
    </nav>
  );
}

function HeroSection() {
  return (
    <section
      id="hero"
      className="h-screen flex items-center justify-center relative overflow-hidden"
    >
      {/* Video Background */}
      <video
        autoPlay
        muted
        loop
        className="absolute inset-0 w-full h-full object-cover z-0"
      >
        <source src="/videos/greenbite-hero.mp4" type="video/mp4" />
        Your browser does not support the video tag.
      </video>
      <div className="absolute inset-0 bg-black opacity-50 z-10"></div>
      <motion.div
        initial={{ opacity: 0, y: 50 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 1 }}
        className="relative z-20 text-center px-6"
      >
        <h1 className="text-5xl md:text-7xl font-extrabold mb-4 text-green-400 drop-shadow-2xl">
          Eat Green, Live Clean
        </h1>
        <p className="text-xl md:text-2xl mb-8 text-gray-200">
          Join the sustainable food revolution and earn rewards with every meal.
        </p>
        <motion.button
          whileHover={{ scale: 1.05 }}
          className="px-8 py-4 bg-green-600 rounded-full text-white text-lg font-semibold transition relative overflow-hidden"
        >
          Get Started
          <div className="absolute inset-0 overflow-hidden">
            <div className="glint-effect"></div>
          </div>
        </motion.button>
      </motion.div>
    </section>
  );
}

function VisionSection() {
  const controls = useAnimation();
  const [ref, inView] = useInView({ triggerOnce: true });

  useEffect(() => {
    if (inView) {
      controls.start("visible");
    }
  }, [controls, inView]);

  return (
    <section
      id="vision"
      className="py-20 bg-gradient-to-r from-green-700 to-green-900 text-center"
    >
      <motion.h2
        ref={ref}
        initial="hidden"
        animate={controls}
        variants={{
          hidden: { opacity: 0, y: 50 },
          visible: { opacity: 1, y: 0 },
        }}
        transition={{ duration: 0.8 }}
        className="text-4xl font-bold mb-4"
      >
        Our Vision
      </motion.h2>
      <motion.p
        initial="hidden"
        animate={controls}
        variants={{
          hidden: { opacity: 0, y: 50 },
          visible: { opacity: 1, y: 0 },
        }}
        transition={{ duration: 0.8, delay: 0.3 }}
        className="max-w-3xl mx-auto text-lg text-gray-200"
      >
        At GreenBite, we are dedicated to transforming the way you dine. Our goal is to empower healthy, eco-friendly living by rewarding sustainable choices.
      </motion.p>
    </section>
  );
}

function FeaturesSection() {
  const features = [
    { icon: FaLeaf, title: "Earn Rewards", description: "Gain points for every eco-friendly purchase." },
    { icon: FaShoppingCart, title: "Exclusive Deals", description: "Redeem your points for amazing discounts and offers." },
    { icon: FaGlobe, title: "Sustainable Impact", description: "Join a community committed to a greener planet." },
  ];

  return (
    <section id="features" className="py-20 bg-white text-gray-800">
      <h2 className="text-4xl font-bold text-center text-green-700 mb-12">Features</h2>
      <div className="max-w-6xl mx-auto grid grid-cols-1 md:grid-cols-3 gap-8 px-4">
        {features.map((feature, index) => (
          <FeatureCard key={index} feature={feature} index={index} />
        ))}
      </div>
    </section>
  );
}

function FeatureCard({ feature, index }) {
  const controls = useAnimation();
  const [ref, inView] = useInView({ triggerOnce: true });

  useEffect(() => {
    if (inView) {
      controls.start("visible");
    }
  }, [controls, inView]);

  return (
    <motion.div
      ref={ref}
      initial="hidden"
      animate={controls}
      variants={{
        hidden: { opacity: 0, y: 30 },
        visible: { opacity: 1, y: 0 },
      }}
      transition={{ duration: 0.8, delay: index * 0.2 }}
      className="bg-green-50 p-6 rounded-lg shadow-lg text-center"
    >
      <div className="text-6xl mb-4 mx-auto">
        <feature.icon className="text-green-600" />
      </div>
      <h3 className="text-2xl font-semibold text-green-700 mb-2">{feature.title}</h3>
      <p className="text-gray-600">{feature.description}</p>
    </motion.div>
  );
}

function TestimonialsSection() {
  const testimonials = [
    { name: "Jane Doe", text: "GreenBite has transformed my dining experience! I earn rewards while enjoying delicious, healthy meals.", avatar: "https://randomuser.me/api/portraits/women/44.jpg" },
    { name: "John Smith", text: "The sustainable choices and exclusive deals make every meal a win. I highly recommend GreenBite!", avatar: "https://randomuser.me/api/portraits/men/46.jpg" },
  ];

  return (
    <section id="testimonials" className="py-20 bg-green-100">
      <h2 className="text-4xl font-bold text-center text-green-700 mb-12">Testimonials</h2>
      <div className="max-w-4xl mx-auto flex flex-col md:flex-row gap-8 justify-center">
        {testimonials.map((t, index) => (
          <TestimonialCard key={index} testimonial={t} index={index} />
        ))}
      </div>
    </section>
  );
}

function TestimonialCard({ testimonial, index }) {
  const controls = useAnimation();
  const [ref, inView] = useInView({ triggerOnce: true });

  useEffect(() => {
    if (inView) {
      controls.start("visible");
    }
  }, [controls, inView]);

  return (
    <motion.div
      ref={ref}
      initial="hidden"
      animate={controls}
      variants={{
        hidden: { opacity: 0, scale: 0.9 },
        visible: { opacity: 1, scale: 1 },
      }}
      transition={{ duration: 0.8, delay: index * 0.2 }}
      className="bg-white p-6 rounded-lg shadow-lg flex items-center space-x-4"
    >
      <img src={testimonial.avatar} alt={testimonial.name} className="w-16 h-16 rounded-full" />
      <div>
        <p className="text-gray-600 italic">"{testimonial.text}"</p>
        <h4 className="mt-2 font-bold text-green-700">- {testimonial.name}</h4>
      </div>
    </motion.div>
  );
}

function CallToActionSection() {
  return (
    <section id="contact" className="py-20 bg-gradient-to-r from-green-600 to-green-800 text-center">
      <h2 className="text-4xl font-bold text-white mb-6">Ready to Join the Revolution?</h2>
      <p className="text-lg text-gray-200 mb-8">
        Sign up today to start earning rewards and enjoy exclusive benefits.
      </p>
      <motion.button
        whileHover={{ scale: 1.1 }}
        className="px-8 py-4 bg-white text-green-700 font-bold rounded-full shadow-md transition duration-300 relative overflow-hidden"
      >
        Sign Up Now
        <div className="absolute inset-0 overflow-hidden">
          <div className="glint-effect"></div>
        </div>
      </motion.button>
    </section>
  );
}

function Footer() {
  return (
    <footer className="bg-green-900 text-white text-center p-6">
      <p>© {new Date().getFullYear()} GreenBite. All rights reserved.</p>
      <div className="flex justify-center space-x-6 mt-2">
        <a href="#" className="hover:underline">Privacy</a>
        <a href="#" className="hover:underline">Terms</a>
        <a href="#" className="hover:underline">Contact</a>
      </div>
    </footer>
  );
}