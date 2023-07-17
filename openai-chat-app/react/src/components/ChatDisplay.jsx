const ChatDisplay = ({ chatHistory }) => {
  return (
    <div className="chat">
      {chatHistory.map((chat, index) => (
        <div key={index} className={`message ${chat.type}`}>
          <div dangerouslySetInnerHTML={{ __html: chat.message }}></div>
        </div>
      ))}
    </div>
  );
};

export default ChatDisplay;
