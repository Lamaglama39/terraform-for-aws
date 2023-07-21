import React, { useState, useEffect } from "react";
import ChatDisplay from "./components/ChatDisplay";
import ChatForm from "./components/ChatForm";
import useLoadChatApi from "./components/useLoadChatApi";
import "./App.css";

const App = () => {
  const loadUrl = import.meta.env.VITE_LAMBDA_URL;
  const loadParams = { load: "True" };
  const [chatHistory, setChatHistory] = useState([]);
  const { isLoading, fetchChatResponse } = useLoadChatApi();

  const onSuccess = (messages) => {
    setChatHistory(messages);
  };

  // 初回ロード時にfetchChatResponseを呼び出す
  useEffect(() => {
    fetchChatResponse(loadUrl, loadParams, onSuccess);
  }, []);

  return (
    <div className="page">
      <ChatDisplay chatHistory={chatHistory} />
      <ChatForm chatHistory={chatHistory} setChatHistory={setChatHistory} />
    </div>
  );
};

export default App;
