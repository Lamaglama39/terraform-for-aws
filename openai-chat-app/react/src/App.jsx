import { useState } from "react";
import ChatDisplay from "./components/ChatDisplay";
import ChatForm from "./components/ChatForm";
import "./App.css";

const App = () => {
  const [chatHistory, setChatHistory] = useState([]);
  return (
    <div>
      <ChatDisplay chatHistory={chatHistory} />
      <ChatForm chatHistory={chatHistory} setChatHistory={setChatHistory} />
    </div>
  );
};

export default App;
