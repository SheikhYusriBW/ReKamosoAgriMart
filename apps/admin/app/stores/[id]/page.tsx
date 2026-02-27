export default function StoreDetailPage({ params }: { params: { id: string } }) {
  return (
    <div>
      <h1>Store Detail: {params.id}</h1>
    </div>
  );
}
